require 'rails_helper'

RSpec.describe ExternalUsers::Admin::ExternalUsersController, type: :controller do
  let(:provider) { create(:provider) }

  context 'admin user' do
    let(:admin) { create(:external_user, :admin, provider: provider) }

    subject { create(:external_user, provider: provider) }

    before { sign_in admin.user }

    describe 'GET #index' do
      it 'returns http success' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @eternal_users' do
        external_user = create(:external_user, provider: admin.provider)
        other_provider_external_user = create(:external_user)
        get :index
        expect(assigns(:external_users)).to match_array([admin, external_user])
      end

      it 'renders the template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #show' do
      before { get :show, params: { id: subject } }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @external_user' do
        expect(assigns(:external_user)).to eq(subject)
      end

      it 'renders the template' do
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #new' do
      before { get :new }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @external_user' do
        expect(assigns(:external_user)).to be_new_record
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: subject } }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @external_user' do
        expect(assigns(:external_user)).to eq(subject)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end

    describe 'GET #change_password' do
      before { get :change_password, params: { id: subject } }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @external_user' do
        expect(assigns(:external_user)).to eq(subject)
      end

      it 'renders the template' do
        expect(response).to render_template(:change_password)
      end
    end

    describe 'POST #create' do
      context 'when valid' do
        let(:params) {
          {
            external_user: {
              user_attributes: {
                email: 'foo@foobar.com',
                password: 'password',
                password_confirmation: 'password',
                first_name: 'John',
                last_name: 'Smith',
                email_notification_of_message: 'true'
              },
              roles: ['advocate'],
              supplier_number: 'AB124'
            }
          }
        }

        it 'creates a external_user' do
          expect {
            post :create, params: params
          }.to change(User, :count).by(1)
          user = User.find_by_email('foo@foobar.com')
          expect(user.settings).to eq({ 'email_notification_of_message' => true })
        end

        it 'redirects to external_users index' do
          params = {
            external_user: {
              user_attributes: {
                email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith'
              },
              roles: ['advocate'],
              supplier_number: 'XY123'
            }
          }
          post :create, params: params
          expect(response).to redirect_to(external_users_admin_external_users_url)
        end
      end

      context 'when invalid' do
        it 'does not create a external_user' do
          expect {
            post :create, params: { external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, roles: ['advocate'] } }
          }.to_not change(User, :count)
        end

        it 'renders the new template' do
          post :create, params: { external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, roles: ['advocate'] } }
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'PUT #update' do
      context 'when valid' do
        before(:each) { put :update, params: { id: subject, external_user: { roles: ['admin'] } } }

        it 'updates a external_user' do
          subject.reload
          expect(subject.reload.roles).to eq(['admin'])
        end

        it 'redirects to external_users index' do
          expect(response).to redirect_to(external_users_admin_external_users_url)
        end
      end

      context 'when invalid' do
        before(:each) { put :update, params: { id: subject, external_user: { roles: ['foo'] } } }

        it 'does not update external_user' do
          subject.reload
          expect(subject.roles).to eq(['advocate'])
          expect(subject.email).to_not eq('emailexample.com')
        end

        it 'renders the edit template' do
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'PUT #update_password' do
      before do
        subject.user.update(password: 'password', password_confirmation: 'password')
        sign_in subject.user #need to sign in again after password change
      end

      context 'when valid' do
        before(:each) do
          put :update_password, params: { id: subject, external_user: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } } }
        end

        it 'redirects to external_user show action' do
          # put :update_password, id: external_user, external_user: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } }
          expect(response).to redirect_to(external_users_admin_external_user_path(subject))
        end
      end

      context 'when mandatory params for external user are not provided' do
        it 'raises a paramenter missing error' do
          expect {
            put :update_password, params: { id: subject, external_user: {} }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end

      context 'when invalid' do
        it 'renders the change password template' do
          put :update_password, params: { id: subject, external_user: { user_attributes: { foo: 'bar' } } }
          expect(response).to render_template(:change_password)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the external user' do
        subject # create an additional External user
        expect {
          delete :destroy, params: { id: subject }
        }.to change { ExternalUser.active.count }.by(-1)
        expect(subject.reload.deleted_at).not_to be_nil
      end

      it 'redirects to external_user admin root url' do
        delete :destroy, params: { id: subject }
        expect(response).to redirect_to(external_users_admin_external_users_url)
      end
    end
  end

  ######################## NON ADMIN USER #################

  context 'non-admin user' do
    let(:external_user)         { create(:external_user, provider: provider) }
    let(:other_external_user)   { create(:external_user, provider: provider) }

    before do
      2.times { create :user }
      sign_in external_user.user
    end

    describe 'GET #index' do
      it 'redirects to all claims page with Unauthorised in flash' do
        get :index
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end
    end

    describe 'GET #show' do
      it 'displays the show page for the current user' do
        get :show, params: { id: external_user }
        expect(response).to be_successful
      end

      it 'doesnt show the details for a different user' do
        get :show, params: { id: other_external_user }
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end
    end

    describe 'GET #new' do
      it 'redirects to all claims page with Unauthorised in flash' do
        get :new
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end
    end

    describe 'POST #create' do
      it 'redirects to all claims page with Unauthorised in flash' do
        get :new
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end
    end

    describe 'GET #edit' do
      it 'displays the edit form' do
        get :edit, params: { id: external_user }
        expect(response).to be_successful
      end
    end

    describe 'PUT #update' do
      context 'current user' do
        it 'updates non-roles attributes' do
          expect(external_user.email).to_not eq 'bobsmith@example.com'
          put :update, params: params_updating_email(external_user)
          expect(external_user.user.reload.email).to eq 'bobsmith@example.com'
        end

        it 'ignores roles attributes' do
          expect(external_user.roles).to eq(['advocate'])
          expect(external_user.email).to_not eq 'bobsmith@example.com'
          put :update, params: params_updating_roles(external_user)
          expect(external_user.reload.roles).to eq(['advocate'])
          expect(external_user.user.reload.email).to eq 'bobsmith@example.com'
        end

        it 'redirects to external_users index' do
          put :update, params: { id: external_user, external_user: { email: 'bobsmith@example.com' } }
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'other user' do
        it 'does not allow any updates' do
          put :update, params: params_updating_email(other_external_user)
          expect(response).to redirect_to(external_users_root_path)
          expect(flash[:alert]).to eq 'Unauthorised'
        end
      end
    end
    describe 'DELETE #destroy' do
      it 'does not allow user to delete himself' do
        delete :destroy, params: { id: external_user }
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end

      it 'does not allow user to delete other user' do
        delete :destroy, params: { id: other_external_user }
        expect(response).to redirect_to(external_users_root_path)
        expect(flash[:alert]).to eq 'Unauthorised'
      end
    end

    def params_updating_roles(external_user)
        { id: external_user,
          external_user: {
            user_attributes: {
              id: external_user.user.id,
              email: 'bobsmith@example.com'
            }
          },
          roles: %w{admin advocate litigator}
        }.with_indifferent_access
    end

    def params_updating_email(external_user)
        { id: external_user,
          external_user: {
            user_attributes: {
              id: external_user.user.id,
              email: 'bobsmith@example.com'
            }
          }
        }.with_indifferent_access
    end
  end
end
