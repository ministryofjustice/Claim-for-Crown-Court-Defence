# frozen_string_literal: true

RSpec.shared_examples 'external user not created' do
  it { expect { request }.not_to change(User, :count) }
  it { expect { request }.not_to change(ExternalUser, :count) }
  it { expect { request }.not_to change(Provider, :count) }
end

RSpec.shared_examples 'external user created' do
  it { expect { request }.to change(User, :count).by(1) }
  it { expect { request }.to change(ExternalUser, :count).by(1) }
  it { expect { request }.to change(Provider, :count).by(1) }
end

RSpec.describe 'User sign up' do
  include Capybara::RSpecMatchers

  describe 'GET #new' do
    subject(:request) { get new_user_registration_path }

    context 'when NOT on api-sandbox' do
      around do |example|
        with_env('staging') do
          example.run
        end
      end

      it {
        request
        expect(response).to redirect_to(external_users_root_url)
      }
    end

    context 'when on api-sandbox' do
      around do |example|
        with_env('api-sandbox') do
          example.run
        end
      end

      it {
        request
        expect(response).to render_template('devise/registrations/new')
      }

      it {
        request
        expect(response.body).to have_link('software vendor terms and conditions', href: vendor_tandcs_page_path)
      }
    end
  end

  # rubocop:disable RSpec/AnyInstance
  describe 'POST #create' do
    subject(:request) { post '/users', params: { user: sign_up_attributes } }

    let(:sign_up_attributes) do
      { first_name: 'Bob',
        last_name: 'Smith',
        email: 'foo@bar.com',
        password: 'PasswordForTest',
        password_confirmation: 'PasswordForTest',
        terms_and_conditions: '1' }
    end

    context 'when not on api-sandbox but attributes valid' do
      around do |example|
        with_env('staging') do
          example.run
        end
      end

      it {
        request
        expect(response).to redirect_to(external_users_root_url)
      }

      include_examples 'external user not created'
    end

    context 'when on api-sandbox' do
      around do |example|
        with_env('api-sandbox') do
          example.run
        end
      end

      context 'with success' do
        it {
          request
          expect(response).to redirect_to(external_users_root_url)
        }

        include_examples 'external user created'

        it 'sets flash to indicate success' do
          request
          expect(flash[:notice]).to match(/You have signed up successfully/)
        end
      end

      # NOTE: For the user to reach a state of active_for_authentication? => false, the user would
      # have to already exist and have been soft deleted. Given this is a registrations
      # sign up request it is unclear how this would ever happen.
      #
      context 'with success, but created user is inactive' do
        before do
          allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
          allow_any_instance_of(User).to receive(:inactive_message).and_return(:inactive)
        end

        it {
          request
          expect(response).to redirect_to(unauthenticated_root_path)
        }

        include_examples 'external user created'

        it 'sets flash to indicate inactive status' do
          request
          expect(flash[:notice]).to match(/signed up successfully.*account is not yet activated/)
        end
      end

      context 'with success, but created user is inactive and locked' do
        before do
          allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
          allow_any_instance_of(User).to receive(:inactive_message).and_return(:locked)
        end

        it {
          request
          expect(response).to redirect_to(unauthenticated_root_path)
        }

        include_examples 'external user created'

        it 'sets flash to indicate locked status' do
          request
          expect(flash[:notice]).to match(/signed up successfully.* is locked/)
        end
      end

      context 'without invalid user attributes supplied' do
        let(:sign_up_attributes) do
          { first_name: '',
            last_name: '',
            email: '',
            password: '',
            password_confirmation: '',
            terms_and_conditions: '0' }
        end

        it {
          request
          expect(response).to render_template('devise/registrations/new')
        }

        it {
          request
          expect(response.body).to have_css('.govuk-error-summary', text: 'Enter an email')
            .and have_css('.govuk-error-summary', text: 'Enter a first name')
            .and have_css('.govuk-error-summary', text: 'Enter a last name')
            .and have_css('.govuk-error-summary', text: 'Enter a password')
        }

        it {
          request
          expect(response.body).to have_css('.govuk-error-summary', text: 'You must accept the terms and conditions')
        }

        include_examples 'external user not created'
      end
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
