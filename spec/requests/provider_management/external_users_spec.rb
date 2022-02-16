require 'rails_helper'
require 'json'

RSpec.describe 'Providers external users management', type: :request do
  let(:case_worker_manager) { create(:case_worker, :provider_manager) }
  let(:provider) { create(:provider) }
  let!(:external_user) { create(:external_user, :admin, provider: provider) }

  before { sign_in case_worker_manager.user }

  describe 'GET /provider_management/providers/:provider_id/external_users/:id' do
    before { get provider_management_provider_external_user_path(provider_id: provider, id: external_user) }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end
  end

  describe 'GET /provider_management/providers/:provider_id/external_users' do
    before { get provider_management_provider_external_users_path(provider_id: provider) }

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

  describe 'GET /provider_management/external_users/find' do
    before { get provider_management_external_users_find_path }

    it 'returns http success' do
      expect(response).to be_successful
    end
  end

  describe 'POST /provider_management/external_users/find' do
    subject { response }

    before { post provider_management_external_users_find_path, params: { external_user: { email: email } } }

    context 'when the email is for a provider' do
      let(:email) { external_user.email }

      it { is_expected.to redirect_to(provider_management_provider_external_user_path(provider, external_user)) }
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

  describe 'GET /provider_management/providers/:provider_id/external_users/new' do
    let(:external_user) do
      ExternalUser.new(provider: provider).tap(&:build_user)
    end

    before { get new_provider_management_provider_external_user_path(provider_id: provider) }

    it 'returns http success' do
      expect(response).to be_successful
    end

    # NOTE: use json comparison because we are not interested in
    #       whether the object is the same just that it creates a
    #       new one and builds its user
    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user).to_json).to eq(external_user.to_json)
    end

    it 'builds user for @external_user' do
      expect(assigns(:external_user).user.to_json).to eq(external_user.user.to_json)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /provider_management/providers/:provider_id/external_users' do
    subject(:post_to_create_external_user_action) do
      post provider_management_provider_external_users_path(provider_id: provider), params: params
    end

    let(:params) do
      {
        external_user: {
          user_attributes: {
            email: 'foo@foobar.com',
            email_confirmation: 'foo@foobar.com',
            first_name: 'John',
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
      let(:params) do
        {
          external_user: {
            user_attributes: {
              email: 'foo@foobar.com',
              email_confirmation: 'foo@foobar.com',
              first_name: '',
              last_name: 'Smith'
            },
            roles: ['advocate'],
            supplier_number: 'AB124'
          }
        }
      end

      it 'does not create an external_user' do
        expect { post_to_create_external_user_action }.not_to change(User, :count)
      end

      it 'renders the new template' do
        post_to_create_external_user_action
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /provider_management/providers/:provider_id/external_users/:id/edit' do
    before { get edit_provider_management_provider_external_user_path(provider_id: provider, id: external_user) }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT /provider_management/providers/:provider_id/external_users/:id' do
    context 'when valid' do
      before do
        put(
          provider_management_provider_external_user_path(provider_id: provider, id: external_user),
          params: { external_user: { supplier_number: 'XX100', roles: ['advocate'] } }
        )
      end

      it 'updates an external_user' do
        external_user.reload
        expect(external_user.reload.roles).to eq(['advocate'])
      end

      it 'redirects to external_users index' do
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      before do
        put(
          provider_management_provider_external_user_path(provider_id: provider, id: external_user),
          params: { external_user: { roles: ['foo'] } }
        )
      end

      it 'does not update external_user' do
        external_user.reload
        expect(external_user.roles).to eq(['admin'])
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET /provider_management/providers/:provider_id/external_users/:id/change_password' do
    before do
      get change_password_provider_management_provider_external_user_path(provider_id: provider, id: external_user)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe 'PATCH /provider_management/providers/:provider_id/external_users/:id/update_password' do
    subject(:password_update_request) do
      patch(
        update_password_provider_management_provider_external_user_path(provider_id: provider, id: external_user),
        params: { external_user: { user_attributes: { password: password, password_confirmation: password_confirm } } }
      )
    end

    let(:password) { 'password123' }
    let(:password_confirm) { password }

    before { travel_to(6.months.ago) { external_user } }

    context 'when valid' do
      it 'does not require current password to be successful in updating the user record' do
        expect { password_update_request }.to(change { external_user.reload.user.updated_at })
      end

      it 'redirects to external_user show action' do
        password_update_request
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      let(:password_confirm) { 'passwordxxx' }

      it 'does not update the user record' do
        expect { password_update_request }.not_to(change { external_user.reload.user.updated_at })
      end

      it 'renders the change password template' do
        password_update_request
        expect(response).to render_template(:change_password)
      end
    end
  end

  describe 'PATCH /provider_management/providers/:provider_id/external_users/:id/disable' do
  end

  describe 'PATCH /provider_management/providers/:provider_id/external_users/:id/enable' do
  end
end