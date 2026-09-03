require 'rails_helper'

RSpec.describe 'Session routing' do
  describe 'GET /users/identify' do
    before { get '/users/identify' }

    it 'responds successfully' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the email only sign in page' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /users/identify' do
    context 'with a blank email' do
      before { post '/users/identify', params: { email: '' } }

      it 'responds as unprocessable' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders the form with an error' do
        expect(assigns(:error)).to eq 'Enter your email address'
      end
    end

    context 'with a malformed email' do
      before { post '/users/identify', params: { email: 'not-an-email' } }

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
        post '/users/identify', params: { email: 'Entra@example.com ' }
      end

      it 'redirects to the entra authorisation endpoint' do
        expect(response).to redirect_to '/users/auth/entra_id'
      end
    end

    context 'when the email maps to legacy' do
      before do
        create(:user, email: 'legacy@example.com')
        post '/users/identify', params: { email: 'legacy@example.com' }
      end

      it 'redirects to the password sign in page with the email prefilled' do
        expect(response).to redirect_to new_user_session_path(email: 'legacy@example.com')
      end
    end

    context 'when the email is not mapped' do
      before { post '/users/identify', params: { email: 'unknown@example.com' } }

      it 'redirects to the password sign in page' do
        expect(response).to redirect_to new_user_session_path(email: 'unknown@example.com')
      end
    end
  end
end
