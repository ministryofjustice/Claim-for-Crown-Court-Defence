require 'rails_helper'

# Keep authorization entry and callback transitions in the same scenario.
# rubocop:disable-next RSpec/ExampleLength
RSpec.describe 'Dual-login Entra gating', :aggregate_failures do
  let(:user) { create(:case_worker).user }

  before do
    allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
  end

  around do |example|
    original_mode = OmniAuth.config.test_mode
    original_mocks = OmniAuth.config.mock_auth.dup
    OmniAuth.config.test_mode = true
    example.run
  ensure
    OmniAuth.config.test_mode = original_mode
    OmniAuth.config.mock_auth = original_mocks
  end

  def identify_entra(approved: true)
    user.login_route.update!(login_method: LoginRoute::ENTRA, dual_login_tester: approved)
    post dual_login_path, params: { email: user.email }
    OmniAuth.config.add_mock(:entra_id, uid: 'test-uid', info: { email: user.email }, extra: { raw_info: {} })
  end

  def expect_rejection
    expect(response).to redirect_to sign_in_path
    follow_redirect!
    expect(response.body).to include(I18n.t('session_routing.unavailable'))
  end

  %w[entra_id entra_mock].product([false, true]).each do |provider, enabled|
    it "blocks direct #{provider} entry and callbacks without flow state with rollout #{enabled}" do
      allow(Settings).to receive(:dual_login_enabled?).and_return(enabled)
      get "/users/auth/#{provider}"
      expect(response).to redirect_to sign_in_path
      post "/users/auth/#{provider}"
      expect(response).to redirect_to sign_in_path
      expect { get "/users/auth/#{provider}/callback" }.not_to change(User, :count)
      expect(response).to redirect_to sign_in_path
    end
  end

  it 'blocks direct real-provider entry before any external request' do
    OmniAuth.config.test_mode = false
    get '/users/auth/entra_id'
    expect_rejection
  end

  it 'blocks Entra entry after identifying a legacy account' do
    user.login_route.update!(dual_login_tester: true)
    post dual_login_path, params: { email: user.email }
    get '/users/auth/entra_id'
    expect_rejection
  end

  it 'allows an approved Entra account through entry and callback' do
    identify_entra
    follow_redirect!
    expect(response).to redirect_to '/users/auth/entra_id/callback'
    follow_redirect!
    expect(response).to redirect_to case_workers_root_path
    expect(request.env['warden'].user.id).to eq user.id
  end

  it 'rejects revocation between identification and entry' do
    identify_entra
    user.login_route.update!(dual_login_tester: false)
    get '/users/auth/entra_id'
    expect_rejection
  end

  it 'rejects revocation between entry and callback without account side effects' do
    identify_entra
    follow_redirect!
    user.login_route.update!(dual_login_tester: false)
    expect { follow_redirect! }.not_to change { user.reload.sign_in_count }
    expect_rejection
  end

  it 'allows public rollout without approval but rechecks if switched off mid-flow' do
    allow(Settings).to receive(:dual_login_enabled?).and_return(true)
    identify_entra(approved: false)
    follow_redirect!
    allow(Settings).to receive(:dual_login_enabled?).and_return(false)
    follow_redirect!
    expect_rejection
  end

  it 'allows unapproved Entra accounts during public rollout' do
    allow(Settings).to receive(:dual_login_enabled?).and_return(true)
    identify_entra(approved: false)
    follow_redirect!
    follow_redirect!
    expect(response).to redirect_to case_workers_root_path
  end

  it 'rejects mismatched callback identity without provisioning an account' do
    identify_entra
    OmniAuth.config.add_mock(:entra_id, uid: 'other-uid', info: { email: 'unknown@example.com' })
    follow_redirect!
    expect { follow_redirect! }.not_to change(User, :count)
    expect(response).to redirect_to sign_in_path
    expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.email_mismatch')
    get '/users/auth/entra_id'
    expect(response).to redirect_to sign_in_path
  end

  it 'clears state on provider failure' do
    identify_entra
    get '/users/auth/failure', params: { message: 'access_denied' }
    expect(response).to redirect_to sign_in_path
    get '/users/auth/entra_id'
    expect(response).to redirect_to sign_in_path
  end

  it 'recovers from a provider authentication failure without retaining state' do
    identify_entra
    OmniAuth.config.mock_auth[:entra_id] = :access_denied
    follow_redirect!
    follow_redirect!
    expect(response).to redirect_to sign_in_path
    get '/users/auth/entra_id'
    expect(response).to redirect_to sign_in_path
  end

  it 'supports the real local mock strategy after approved identification' do
    identify_entra
    OmniAuth.config.test_mode = false
    payload = { email: user.email, first_name: 'Test', last_name: 'Tester' }.to_json
    Dotenv.modify('ENTRA_MOCK_JSON' => payload, 'ENTRA_MOCK_HTTP_STATUS' => '200') do
      get '/users/auth/entra_mock'
      follow_redirect!
      expect(response).to redirect_to case_workers_root_path
    end
  end

  it 'rejects the master switch being disabled before the callback' do
    allow(Settings).to receive_messages(dual_login_enabled?: true)
    identify_entra(approved: false)
    follow_redirect!
    allow(Settings).to receive_messages(feature_flags_enabled?: false)
    follow_redirect!
    expect_rejection
  end
end
