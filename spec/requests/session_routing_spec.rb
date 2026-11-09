require 'rails_helper'

RSpec.describe 'Session routing' do
  before { allow(Settings).to receive(:dual_login_enabled?).and_return(true) }

  describe 'GET /users/dual_login' do
    before { get dual_login_path }

    it 'responds successfully' do
      expect(response).to have_http_status(:success)
    end

    it 'does not mark the email field as invalid or reference a missing error', :aggregate_failures do
      expect(response.parsed_body.at_css('input#email').attributes.keys)
        .not_to include('aria-invalid')
      expect(response.parsed_body.at_css('input#email')['aria-describedby']).to eq 'email-hint'
    end

    it 'shows the sign-in heading and button', :aggregate_failures do
      expect(Capybara.string(response.body)).to have_css('h1.govuk-heading-l', text: 'Sign in')
      expect(Capybara.string(response.body)).to have_button('Sign in')
    end

    it 'places the email hint between the label and input', :aggregate_failures do
      expect(Capybara.string(response.body)).to have_css(
        'label[for="email"] + #email-hint.govuk-hint',
        text: 'We’ll use your email address to find the right way for you to sign in.'
      )
      expect(Capybara.string(response.body)).to have_css('#email-hint + input#email')
    end
  end

  describe 'POST /users/dual_login' do
    shared_examples 'an accessible email error' do
      it 'associates the invalid email field with its inline error' do
        expect(Capybara.string(response.body)).to have_css(
          'input#email[aria-invalid="true"][aria-describedby="email-hint email-error"]'
        )
      end

      it 'gives the inline error a unique matching ID' do
        expect(Capybara.string(response.body)).to have_css(
          '#email-error.govuk-error-message', text: assigns(:error), count: 1
        )
      end

      it 'links the error summary to the email field' do
        expect(Capybara.string(response.body)).to have_css(
          '.govuk-error-summary a[href="#email"]', text: assigns(:error)
        )
      end
    end

    context 'with a blank email' do
      before { post dual_login_path, params: { email: '' } }

      it_behaves_like 'an accessible email error'

      it 'responds as unprocessable' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders the form with an error' do
        expect(assigns(:error)).to eq 'Enter your email address'
      end
    end

    context 'with a malformed email' do
      before { post dual_login_path, params: { email: 'not-an-email' } }

      it_behaves_like 'an accessible email error'

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
        post dual_login_path, params: { email: 'Entra@example.com ' }
      end

      it 'redirects to the entra authorisation endpoint' do
        expect(response).to redirect_to '/users/auth/entra_id'
      end
    end

    context 'when the email maps to legacy' do
      before do
        create(:user, email: 'legacy@example.com')
        post dual_login_path, params: { email: 'legacy@example.com' }
      end

      it 'redirects to the legacy password sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when the email is not mapped' do
      before { post dual_login_path, params: { email: 'unknown@example.com' } }

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
        post dual_login_path, params: { email: 'legacy@example.com' }
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
