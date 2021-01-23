require 'rails_helper'

RSpec.describe ExternalUsers::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    subject(:perform_post) { post :create, params: { user: sign_up_attributes } }

    let(:sign_up_attributes) do
      { first_name: 'Bob',
        last_name: 'Smith',
        email: 'foo@bar.com',
        password: 'password1234',
        password_confirmation: 'password1234',
        terms_and_conditions: '1' }
    end

    context 'when env not api-sandbox but attributes valid' do
      around do |example|
        with_env('production') do
          example.run
        end
      end

      it { expect(perform_post).to redirect_to(external_users_root_url) }
      it { expect { perform_post }.to change(User, :count).by(0) }
      it { expect { perform_post }.to change(ExternalUser, :count).by(0) }
      it { expect { perform_post }.to change(Provider, :count).by(0) }
    end

    context 'when env api-sandbox' do
      around do |example|
        with_env('api-sandbox') do
          example.run
        end
      end

      context 'with valid attributes' do
        it { expect { perform_post }.to change(User, :count).by(1) }
        it { expect { perform_post }.to change(ExternalUser, :count).by(1) }
        it { expect { perform_post }.to change(Provider, :count).by(1) }

        context 'when the created user is not active_for_authentication?' do
          before do
            # NOTE: For the user to reach this context, the user would have to already exist
            # and have been soft deleted. Given this is the registrations controller I'm not
            # sure how this would ever happen :S (confused)
            resource = double(User)
            external_user = double(ExternalUser)

            allow(controller).to receive(:resource).and_return(resource)
            allow(resource).to receive(:save).and_return(true)
            allow(resource).to receive(:persisted?).and_return(true)
            allow(controller).to receive(:create_external_user).and_return(resource)
            allow(ExternalUser).to receive(:new).and_return(external_user)
            allow(resource).to receive(:reload)
            allow(resource).to receive(:active_for_authentication?).and_return(false)
            allow(resource).to receive(:inactive_message).and_return(:locked)
            allow(external_user).to receive(:user=)
            allow(external_user).to receive(:save!)
            allow(controller).to receive(:after_inactive_sign_up_path_for).with(resource).and_return('/')
            perform_post
          end

          it 'sets flash to indicate locked status' do
            expect(flash[:notice]).to eq I18n.t('devise.registrations.signed_up_but_locked')
          end

          it 'redirects to the inactive sign up path' do
            expect(response).to redirect_to('/')
          end
        end
      end

      context 'with missing persisted user attribute' do
        let(:sign_up_attributes) do
          { first_name: 'Bob',
            last_name: 'Smith',
            email: '',
            password: 'password1234',
            password_confirmation: 'password1234',
            terms_and_conditions: '1' }
        end

        it { expect { perform_post }.to change(User, :count).by(0) }
        it { expect { perform_post }.to change(ExternalUser, :count).by(0) }
        it { expect { perform_post }.to change(Provider, :count).by(0) }
      end

      context 'with terms and conditions not accepted' do
        let(:sign_up_attributes) do
          { first_name: 'Bob',
            last_name: 'Smith',
            email: 'foo@bar.com',
            password: 'password1234',
            password_confirmation: 'password1234' }
        end

        it { expect(perform_post).to render_template(:new) }
        it { expect { perform_post }.to change(User, :count).by(0) }
        it { expect { perform_post }.to change(ExternalUser, :count).by(0) }
        it { expect { perform_post }.to change(Provider, :count).by(0) }
      end
    end
  end
end
