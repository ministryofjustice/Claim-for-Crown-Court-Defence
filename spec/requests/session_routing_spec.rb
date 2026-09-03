require 'rails_helper'

RSpec.describe 'Session routing' do
  describe 'GET /users/sign_in' do
    before { get sign_in_path }

    it 'responds successfully' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the email only sign in page' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /users/sign_in' do
    context 'with a blank email' do
      before { post sign_in_path, params: { email: '' } }

      it 'responds as unprocessable' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders the form with an error' do
        expect(assigns(:error)).to eq 'Enter your email address'
      end
    end

    context 'with a malformed email' do
      before { post sign_in_path, params: { email: 'not-an-email' } }

      it 'responds as unprocessable' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders the form with an error' do
        expect(assigns(:error)).to eq 'Enter an email address in the correct format, like name@example.com'
      end
    end

    context 'when the email maps to entra' do
      before do
        user = create(:user, email: 'entra@example.com')
        user.login_route.update!(login_method: LoginRoute::ENTRA)
        post sign_in_path, params: { email: 'Entra@example.com ' }
      end

      it 'redirects to the entra authorisation endpoint' do
        expect(response).to redirect_to '/users/auth/entra_id'
      end
    end

    context 'when the email maps to legacy' do
      before do
        create(:user, email: 'legacy@example.com')
        post sign_in_path, params: { email: 'legacy@example.com' }
      end

      it 'redirects to the legacy password sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when the email is not mapped' do
      before { post sign_in_path, params: { email: 'unknown@example.com' } }

      it 'redirects to the password sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /users/legacy_sign_in' do
    context 'without email identification' do
      before { get new_user_session_path }

      it 'redirects to sign in' do
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'when email identification has completed' do
      before do
        post sign_in_path, params: { email: 'legacy@example.com' }
        get new_user_session_path
      end

      it 'renders the legacy password sign in page' do
        expect(response).to have_http_status(:success)
      end

      it 'prefills the identified email address' do
        expect(response.body).to include('value="legacy@example.com"')
      end
    end
  end

  describe 'POST /users/legacy_sign_in' do
    before { post user_session_path, params: { user: { email: 'legacy@example.com', password: 'password-password' } } }

    it 'redirects to sign in without email identification' do
      expect(response).to redirect_to sign_in_path
    end
  end
end
