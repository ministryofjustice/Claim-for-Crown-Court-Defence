require 'rails_helper'

RSpec.describe OmniauthCallbacksController do
  let(:user) { create(:case_worker).user }

  describe 'GET #entra_mock' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(callback_email)
    end

    context 'when the Entra email matches the identified email' do
      let(:callback_email) { user.email.upcase }

      before { session[:entra_sign_in_email] = user.email }

      it 'signs the user in' do
        get :entra_mock
        expect(response).to redirect_to case_workers_root_path
      end
    end

    context 'when the Entra email differs from the identified email' do
      let(:callback_email) { 'other@example.com' }

      before { session[:entra_sign_in_email] = user.email }

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
        expect(session[:entra_sign_in_email]).to be_nil
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

  def omniauth_auth(email)
    OmniAuth::AuthHash.new(info: { email: email }, extra: { raw_info: {} })
  end
end
