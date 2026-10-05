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

      before do
        session[:entra_sign_in_email] = user.email
        session[:multi_firm_primary_user_id] = 123
        get :entra_mock
      end

      it 'signs the user in' do
        expect(response).to redirect_to case_workers_root_path
      end

      it 'clears stale multi-firm session state' do
        expect(session[:multi_firm_primary_user_id]).to be_nil
      end
    end

    context 'when a multi-firm external user has linked accounts' do
      let(:user) { create(:external_user, user: build(:user, multi_firm_user: true)).user }
      let(:callback_email) { user.email }

      before do
        create(:multi_firm_user_link, user:)
        session[:entra_sign_in_email] = user.email
        get :entra_mock
      end

      it 'redirects to account selection before signing in' do
        expect(response).to redirect_to multi_firm_account_selection_path
      end

      it 'does not sign in before account selection' do
        expect(controller.current_user).to be_nil
      end

      it 'retains the primary account for selection' do
        expect(session[:multi_firm_primary_user_id]).to eq(user.id)
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
