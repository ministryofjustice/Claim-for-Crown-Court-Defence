require 'rails_helper'

# Keep the real strategy's authorization and callback phases in the same example.
# rubocop:disable-next RSpec/ExampleLength, RSpec/MultipleMemoizedHelpers
RSpec.describe 'Dual-login OpenID Connect authentication', :aggregate_failures do
  let(:user) { create(:case_worker, :admin).user }
  let(:issuer) { "https://login.example.com/#{SecureRandom.uuid}/v2.0" }
  let(:client_id) { 'cccd-test-client' }
  let(:callback_url) { 'http://www.example.com/users/auth/entra_id/callback' }
  let(:signing_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:token_signing_key) { signing_key }
  let(:roles) { ['Caseworker'] }
  let(:claim_source) { :id_token }
  let(:identity_claims) { { email: user.email.upcase, LAA_ROLES: roles } }

  before do
    allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
    user.login_route.update!(login_method: LoginRoute::ENTRA, dual_login_tester: true)
    allow(OmniAuth.config).to receive_messages(
      test_mode: false,
      before_request_phase: method(:configure_provider),
      before_callback_phase: method(:configure_provider)
    )
    stub_provider_endpoints
  end

  %i[id_token userinfo].each do |source|
    context "with SiLAS claims in #{source}" do
      let(:claim_source) { source }

      it 'maps the email and replaces stored administrator permissions before signing in' do
        complete_oidc_flow

        expect(request.env['warden'].user).to eq user
        expect(user.persona.reload.roles).to eq ['case_worker']
        expect(response).to redirect_to case_workers_root_path
        expect(WebMock).to have_requested(:get, "#{issuer}/keys")
        expect(WebMock).to have_requested(:get, "#{issuer}/userinfo")
      end
    end
  end

  context 'when SiLAS grants beta tester access' do
    let(:roles) { ['Caseworker', 'Beta Tester'] }

    it 'synchronises beta tester access before signing in' do
      complete_oidc_flow
      expect(request.env['warden'].user).to eq user
      expect(user.persona.reload.roles).to eq %w[case_worker beta_tester]
      expect(response).to redirect_to case_workers_root_path
    end
  end

  context 'when SiLAS revokes beta tester access' do
    let(:user) { create(:case_worker, roles: %w[case_worker beta_tester]).user }

    it 'removes beta tester access before signing in' do
      complete_oidc_flow
      expect(request.env['warden'].user).to eq user
      expect(user.persona.reload.roles).to eq ['case_worker']
      expect(response).to redirect_to case_workers_root_path
    end
  end

  context 'when SiLAS supplies only the beta tester role' do
    let(:roles) { ['Beta Tester'] }

    it 'rejects sign-in without changing stored permissions or retaining identification' do
      expect { complete_oidc_flow }.not_to change { user.reload.sign_in_count }
      expect(user.persona.reload.roles).to eq ['admin']
      expect(request.env['warden'].user).to be_nil
      expect(response).to redirect_to sign_in_path
      expect(flash[:error_summary]).to eq I18n.t('omniauth_callbacks.role_error')
      get '/users/auth/entra_id'
      expect(response).to redirect_to sign_in_path
    end
  end

  context 'when SiLAS explicitly removes all roles' do
    let(:roles) { [] }

    it 'rejects sign-in without changing stored permissions or retaining identification' do
      expect { complete_oidc_flow }.not_to change { user.reload.sign_in_count }

      expect(user.persona.reload.roles).to eq ['admin']
      expect(request.env['warden'].user).to be_nil
      expect(response).to redirect_to sign_in_path
      expect(flash[:error_summary]).to eq I18n.t('omniauth_callbacks.role_error')
      get '/users/auth/entra_id'
      expect(response).to redirect_to sign_in_path
    end
  end

  context 'when SiLAS omits the role claim' do
    let(:identity_claims) { { email: user.email.upcase } }

    it 'rejects sign-in without changing stored permissions' do
      expect { complete_oidc_flow }.not_to change { user.reload.sign_in_count }
      expect(user.persona.reload.roles).to eq ['admin']
      expect(request.env['warden'].user).to be_nil
      expect(response).to redirect_to sign_in_path
      expect(flash[:error_summary]).to eq I18n.t('omniauth_callbacks.role_error')
    end
  end

  context 'when SiLAS supplies both internal and external roles' do
    let(:roles) { %w[Caseworker Advocate] }

    it 'rejects sign-in without changing stored permissions' do
      expect { complete_oidc_flow }.not_to change { user.reload.sign_in_count }
      expect(user.persona.reload.roles).to eq ['admin']
      expect(request.env['warden'].user).to be_nil
      expect(response).to redirect_to sign_in_path
      expect(flash[:error_summary]).to eq I18n.t('omniauth_callbacks.role_error')
    end
  end

  context 'when the ID token is signed with an untrusted key' do
    let(:token_signing_key) { OpenSSL::PKey::RSA.new(2048) }

    it 'rejects the token before fetching user information or changing the account' do
      expect { complete_oidc_flow }.not_to change { user.reload.sign_in_count }

      expect(WebMock).to have_requested(:get, "#{issuer}/keys")
      expect(WebMock).not_to have_requested(:get, "#{issuer}/userinfo")
      expect(user.persona.reload.roles).to eq ['admin']
      expect(request.env['warden'].user).to be_nil
      expect(response).to redirect_to sign_in_path
      expect(flash[:error_summary]).to eq I18n.t('omniauth_callbacks.authentication_failed')
      get '/users/auth/entra_id'
      expect(response).to redirect_to sign_in_path
    end
  end

  private

  def configure_provider(env)
    # Replace connection settings only; use the registered strategy and its real token verification.
    options = env.fetch('omniauth.strategy').options
    options.issuer = issuer
    options.client_options = options.client_options.merge(
      identifier: client_id, secret: 'test-client-secret', redirect_uri: callback_url
    )
  end

  def stub_provider_endpoints
    stub_request(:get, "#{issuer}/.well-known/openid-configuration")
      .to_return_json(body: discovery_document)
    stub_request(:get, "#{issuer}/keys")
      .to_return_json(body: { keys: [JSON::JWK.new(signing_key.public_key, kid: 'test-key')] })
    stub_userinfo_response
  end

  def stub_userinfo_response
    userinfo = { sub: 'test-entra-user' }
    userinfo.merge!(identity_claims) if claim_source == :userinfo
    stub_request(:get, "#{issuer}/userinfo")
      .with(headers: { 'Authorization' => 'Bearer test-access-token' })
      .to_return_json(body: userinfo)
  end

  def discovery_document
    {
      issuer: issuer,
      authorization_endpoint: "#{issuer}/authorize",
      token_endpoint: "#{issuer}/token",
      userinfo_endpoint: "#{issuer}/userinfo",
      jwks_uri: "#{issuer}/keys",
      response_types_supported: ['code'],
      subject_types_supported: ['public'],
      id_token_signing_alg_values_supported: ['RS256']
    }
  end

  def complete_oidc_flow
    post dual_login_path, params: { email: user.email }
    expect(response).to redirect_to '/users/auth/entra_id'
    follow_redirect!
    parameters = authorization_parameters
    stub_token_exchange(parameters)

    get '/users/auth/entra_id/callback', params: { code: 'test-authorization-code', state: parameters.fetch('state') }
  end

  def authorization_parameters
    expect(response.location).to start_with("#{issuer}/authorize?")
    parameters = URI.decode_www_form(URI(response.location).query).to_h
    expect(parameters).to include('client_id' => client_id, 'code_challenge_method' => 'S256')
    parameters
  end

  def stub_token_exchange(parameters)
    stub_request(:post, "#{issuer}/token")
      .with(body: hash_including(
        'grant_type' => 'authorization_code',
        'code' => 'test-authorization-code',
        'redirect_uri' => callback_url
      )) do |request|
        pkce_challenge(request) == parameters.fetch('code_challenge')
      end
      .to_return_json(body: token_response(parameters.fetch('nonce')))
  end

  def pkce_challenge(request)
    verifier = URI.decode_www_form(request.body).to_h.fetch('code_verifier')
    Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
  end

  def token_response(nonce)
    {
      access_token: 'test-access-token',
      token_type: 'Bearer',
      expires_in: 3600,
      id_token: signed_id_token(nonce)
    }
  end

  def signed_id_token(nonce)
    claims = {
      iss: issuer, sub: 'test-entra-user', aud: client_id,
      iat: Time.current.to_i, exp: 5.minutes.from_now.to_i, nonce: nonce
    }
    claims.merge!(identity_claims) if claim_source == :id_token
    token = JSON::JWT.new(claims)
    token.kid = 'test-key'
    token.sign(token_signing_key, :RS256).to_s
  end
end
