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
        it { expect(perform_post).to redirect_to(external_users_root_url) }
        it { expect { perform_post }.to change(User, :count).by(1) }
        it { expect { perform_post }.to change(ExternalUser, :count).by(1) }
        it { expect { perform_post }.to change(Provider, :count).by(1) }

        it 'sets flash to indicate success' do
          perform_post
          expect(flash[:notice]).to match(/You have signed up successfully/)
        end

        context 'when the created user is not active_for_authentication?' do
          before do
            # NOTE: For the user to reach this context, the user would have to already exist
            # and have been soft deleted. Given this is the registrations controller I'm not
            # sure how this would ever happen :S (confused)
            allow(controller).to receive(:resource).and_return(user)
            allow(user).to receive(:active_for_authentication?).and_return(false)
          end

          let(:user) { build(:user, **sign_up_attributes) }

          context 'with locked status' do
            before do
              allow(user).to receive(:inactive_message).and_return(:locked)
              perform_post
            end

            it { expect(response).to redirect_to('/') }

            it 'sets flash to indicate locked status' do
              expect(flash[:notice]).to match(/signed up successfully.* is locked/)
            end
          end

          context 'with inactive status' do
            before do
              allow(user).to receive(:inactive_message).and_return(:inactive)
              perform_post
            end

            it { expect(response).to redirect_to('/') }

            it 'sets flash to indicate inactiveq status' do
              expect(flash[:notice]).to match(/signed up successfully.*account is not yet activated/)
            end
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
