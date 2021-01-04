require 'rails_helper'

RSpec.describe ExternalUsers::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:email) { Faker::Internet.email }
    let(:sign_up_attributes) do
      {
        first_name: 'Bob',
        last_name: 'Smith',
        email: email,
        password: 'password1234',
        password_confirmation: 'password1234'
      }
    end

    context 'when env not api-sandbox' do
      before { post :create, params: { user: sign_up_attributes, terms_and_conditions_acceptance: '1' } }

      it 'redirects to user sign up path' do
        expect(response).to redirect_to(external_users_root_url)
      end

      it 'does not create a user' do
        expect(User.count).to eq(0)
      end

      it 'does not create an external user' do
        expect(ExternalUser.count).to eq(0)
      end

      it 'does not create a provider' do
        expect(Provider.count).to eq(0)
      end
    end

    context 'when env api-sandbox' do
      around do |example|
        with_env('api-sandbox') { example.run }
      end

      context 'when valid' do
        context 'and terms and conditions are accepted' do
          before { post :create, params: { user: sign_up_attributes, terms_and_conditions_acceptance: '1' } }

          it 'creates a user' do
            expect(User.first.email).to eq(email)
          end

          it 'creates an external user' do
            expect(User.first.persona).to be_a(ExternalUser)
          end

          it 'creates a provider' do
            expect(User.first.persona.provider).to_not eq(nil)
          end
        end

        xcontext 'when the created user is not active_for_authentication?' do
          before do
            # NOTE: For the user to reach this context, the user would have to already exist
            # and have been soft deleted. Given this is the registrations controller I'm not
            # sure how this would ever happen :S (confused)
            resource = double(User)
            allow(resource).to receive(:inactive_message).and_return(:locked)
            allow(resource).to receive(:save).and_return(true)
            allow(resource).to receive(:persisted?).and_return(true)
            allow(resource).to receive(:active_for_authentication?).and_return(false)
            allow(controller).to receive(:resource).and_return(resource)
            allow(controller).to receive(:create_external_user).and_return(resource)
            allow(controller).to receive(:after_inactive_sign_up_path_for).with(resource).and_return('/')
            post :create, params: { user: sign_up_attributes, terms_and_conditions_acceptance: '1' }
          end

          it 'redirects to the inactive sign up path' do
            expect(flash[:notice]).to eq I18n.t('devise.registrations.signed_up_but_locked')
          end

          it 'redirects to the inactive sign up path' do
            expect(response).to redirect_to('/')
          end
        end

        context 'and terms and conditions are not accepted' do
          before { post :create, params: { user: sign_up_attributes } }

          it 'redirects to the sign up path' do
            expect(response).to redirect_to(new_user_registration_path)
          end

          it 'does not create a user' do
            expect(User.count).to eq(0)
          end

          it 'does not create an external user' do
            expect(ExternalUser.count).to eq(0)
          end

          it 'does not create a provider' do
            expect(Provider.count).to eq(0)
          end
        end
      end

      context 'when invalid' do
        before do
          sign_up_attributes.delete(:email)
          post :create, params: { user: sign_up_attributes }
        end

        it 'does not create a user' do
          expect(User.count).to eq(0)
        end

        it 'does not create an external user' do
          expect(ExternalUser.count).to eq(0)
        end

        it 'does not create a provider' do
          expect(Provider.count).to eq(0)
        end
      end
    end
  end
end
