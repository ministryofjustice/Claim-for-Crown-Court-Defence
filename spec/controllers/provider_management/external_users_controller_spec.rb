require 'rails_helper'
require 'json'

RSpec.describe ProviderManagement::ExternalUsersController, type: :controller do
  let(:case_worker_manager) { create(:case_worker, :provider_manager) }
  let(:provider) { create(:provider) }
  let(:external_user) { create(:external_user, :admin, provider: provider) }

  before { sign_in case_worker_manager.user }

  describe 'GET #show' do
    before { get :show, params: { provider_id: provider, id: external_user } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider and @external_user' do
      expect(assigns(:provider)).to eq(provider)
      expect(assigns(:external_user)).to eq(external_user)
    end
  end

  describe 'GET #index' do
    before { get :index, params: { provider_id: provider } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_users' do
      expect(assigns(:external_users)).to include(external_user)
    end
  end

  describe 'GET #find' do
    before { get :find }

    it 'returns http success' do
      expect(response).to be_successful
    end
  end

  describe 'POST #search' do
    subject { response }

    before { post :search, params: { external_user: { email: email } } }

    context 'when the email is for a provider' do
      let(:email) { external_user.email }

      it { is_expected.to redirect_to(provider_management_provider_external_user_path(external_user.provider, external_user)) }
    end

    context 'when the email is for a non-provider' do
      let(:email) { case_worker_manager.email }

      it { is_expected.to redirect_to(provider_management_external_users_find_path) }
    end

    context 'when the email does not exist' do
      let(:email) { 'vail.email@does.not.exist.com' }

      it { is_expected.to redirect_to(provider_management_external_users_find_path) }
    end
  end

  describe 'GET #new' do
    let(:external_user) do
      ExternalUser.new(provider: provider).tap do |eu|
        eu.build_user
      end
    end

    before { get :new, params: { provider_id: provider } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    # NOTE: use json comparison because we are not interested in
    #       whether the object is the same just that it creates a
    #       new one and builds its user
    it 'assigns @provider and @external_user' do
      expect(assigns(:provider)).to eq(provider)
      expect(assigns(:external_user).to_json).to eq(external_user.to_json)
    end

    it 'builds user for @external_user' do
      expect(assigns(:external_user).user.to_json).to eq(external_user.user.to_json)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    def post_to_create_external_user_action(options = {})
      post :create, params: {
        provider_id: provider,
        external_user: {
          user_attributes: {
            email: 'foo@foobar.com',
            email_confirmation: 'foo@foobar.com',
            first_name: options[:valid] == false ? '' : 'john',
            last_name: 'Smith'
          },
          roles: ['advocate'],
          supplier_number: 'AB124'
        }
      }
    end

    context 'when valid' do
      it 'creates an external_user' do
        expect { post_to_create_external_user_action }.to change(User, :count).by(1)
      end

      it 'redirects to external_users show view' do
        post_to_create_external_user_action
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, ExternalUser.last))
      end
    end

    context 'when invalid' do
      it 'does not create an external_user' do
        expect { post_to_create_external_user_action(valid: false) }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post_to_create_external_user_action(valid: false)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { provider_id: provider, id: external_user } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider and @external_user' do
      expect(assigns(:provider)).to eq(provider)
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT #update' do
    context 'when valid' do
      before(:each) { put :update, params: { provider_id: provider, id: external_user, external_user: { supplier_number: 'XX100', roles: ['advocate'] } } }

      it 'updates an external_user' do
        external_user.reload
        expect(external_user.reload.roles).to eq(['advocate'])
      end

      it 'redirects to external_users index' do
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      before(:each) { put :update, params: { provider_id: provider, id: external_user, external_user: { roles: ['foo'] } } }

      it 'does not update external_user' do
        external_user.reload
        expect(external_user.roles).to eq(['admin'])
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET #change_password' do
    before { get :change_password, params: { provider_id: provider, id: external_user } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider and @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
      expect(assigns(:provider)).to eq(provider)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe 'PUT #update_password' do
    let(:password) { 'password123' }
    let(:password_confirm) { password }
    subject(:password_update_request) do
      put :update_password, params: { provider_id: provider, id: external_user, external_user: { user_attributes: { password: password, password_confirmation: password_confirm } } }
    end

    before(:each) { travel_to(6.months.ago) { external_user } }

    context 'when valid' do
      it 'does not require current password to be successful in updating the user record ' do
        expect { password_update_request }.to change { external_user.reload.user.updated_at }
      end

      it 'redirects to external_user show action' do
        password_update_request
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      let(:password_confirm) { 'passwordxxx' }

      it 'does not update the user record' do
        expect { password_update_request }.not_to change { external_user.reload.user.updated_at }
      end

      it 'renders the change password template' do
        password_update_request
        expect(response).to render_template(:change_password)
      end
    end
  end
end
