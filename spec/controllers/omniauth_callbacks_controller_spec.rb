require 'rails_helper'

RSpec.describe OmniauthCallbacksController, :aggregate_failures do
  let(:user) { create(:case_worker).user }

  describe 'GET #entra_mock' do
    before do
      allow(Settings).to receive(:dual_login_enabled?).and_return(true)
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(callback_email)
    end

    context 'when the Entra email matches the identified email' do
      let(:callback_email) { user.email.upcase }

      before { DualLogin.new(session).identify(user.email) }

      it 'signs the user in' do
        get :entra_mock
        expect(response).to redirect_to case_workers_root_path
      end
    end

    context 'when the Entra email differs from the identified email' do
      let(:callback_email) { 'other@example.com' }

      before { DualLogin.new(session).identify(user.email) }

      it 'does not create a user' do
        expect { get :entra_mock }.not_to change(User, :count)
      end

      it 'returns to sign in' do
        get :entra_mock
        expect(response).to redirect_to sign_in_path
      end

      it 'explains the email mismatch' do
        get :entra_mock
        expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.email_mismatch')
      end

      it 'clears the identified email' do
        get :entra_mock
        expect(session[:dual_login]).to be_nil
      end
    end

    context 'without email identification' do
      let(:callback_email) { user.email }

      it 'returns to sign in' do
        get :entra_mock
        expect(response).to redirect_to sign_in_path
      end
    end
  end

  describe 'callback eligibility' do
    before do
      allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
      user.login_route.update!(login_method: LoginRoute::ENTRA, dual_login_tester: true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(user.email)
      DualLogin.new(session).identify(user.email)
    end

    %i[entra_id entra_mock].each do |callback|
      it "rejects revoked approval in #{callback} before changing roles or signing in" do # rubocop:disable RSpec/ExampleLength
        user.login_route.update!(dual_login_tester: false)
        request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = ['LAA Administrator']
        get callback
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq I18n.t('session_routing.unavailable')
        expect(user.persona.reload.roles).to eq ['case_worker']
        expect(controller.current_user).to be_nil
        expect(session[:dual_login]).to be_nil
      end
    end

    it 'rejects route reassignment before signing in' do
      user.login_route.update!(login_method: LoginRoute::LEGACY)
      get :entra_id
      expect(controller.current_user).to be_nil
      expect(response).to redirect_to sign_in_path
    end
  end

  def omniauth_auth(email)
    OmniAuth::AuthHash.new(info: { email: email }, extra: { raw_info: {} })
  end
end
