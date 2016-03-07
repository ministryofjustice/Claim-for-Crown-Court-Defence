require 'rails_helper'
require 'json'

RSpec.describe SuperAdmins::ExternalUsersController, type: :controller do

  let(:super_admin)   { create(:super_admin) }
  let(:provider)      { create(:provider) }

  let(:frozen_time)  { 6.months.ago }
  let(:external_user)   do
    Timecop.freeze(frozen_time) { create(:external_user, :admin, provider: provider) }
  end

  before { sign_in super_admin.user }


  describe "GET #show" do
    before { get :show, provider_id: provider, id: external_user }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider and @external_user' do
      expect(assigns(:provider)).to eq(provider)
      expect(assigns(:external_user)).to eq(external_user)
    end

  end

  describe "GET #index" do
    before { get :index, provider_id: provider }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_users' do
      expect(assigns(:external_users)).to include(external_user)
    end

  end

  describe "GET #new" do
    let(:external_user) do
     a = ExternalUser.new(provider: provider)
     a.build_user
     a
    end

    before { get :new, provider_id: provider }

    it "returns http success" do
      expect(response).to have_http_status(:success)
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

  describe "POST #create" do

    def post_to_create_external_user_action(options={})
      post :create,
            provider_id: provider,
            external_user: { user_attributes: {  email: 'foo@foobar.com',
                                            first_name: options[:valid]==false ? '' : 'john',
                                            last_name: 'Smith' },
                        roles: ['advocate'],
                        supplier_number: 'AB124' }
    end

    context 'when valid' do
      it 'creates an external_user' do
        expect{ post_to_create_external_user_action }.to change(User, :count).by(1)
      end

      it 'redirects to external_users show view' do
        post_to_create_external_user_action
        expect(response).to redirect_to(super_admins_provider_external_user_path(provider, ExternalUser.last))
      end
    end

    context 'when invalid' do
      it 'does not create an external_user' do
        expect{ post_to_create_external_user_action(valid: false) }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post_to_create_external_user_action(valid: false)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    before { get :edit, provider_id: provider, id: external_user }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

   it 'assigns @provider and @external_user' do
      expect(assigns(:provider)).to eq(provider)
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do

    context 'when valid' do
      before(:each) { put :update, provider_id: provider, id: external_user, external_user: { supplier_number: 'XX100', roles: ['advocate'] } }

      it 'updates an external_user' do
        external_user.reload
        expect(external_user.reload.roles).to eq(['advocate'])
      end

      it 'redirects to external_users index' do
        expect(response).to redirect_to(super_admins_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      before(:each) { put :update, provider_id: provider, id: external_user, external_user: { roles: ['foo'] } }

      it 'does not update external_user' do
        external_user.reload
        expect(external_user.roles).to eq(['admin'])
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "GET #change_password" do
    before { get :change_password, provider_id: provider, id: external_user }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider and @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
      expect(assigns(:provider)).to eq(provider)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe "PUT #update_password" do

    context 'when valid' do

      before(:each) do
        put :update_password, provider_id: provider, id: external_user, external_user: { user_attributes: { password: 'password123', password_confirmation: 'password123' } }
        external_user.reload
      end

      it 'does not require current password to be successful in updating the user record ' do
        expect(external_user.user.updated_at).to_not eql frozen_time
      end

      it 'redirects to external_user show action' do
        expect(response).to redirect_to(super_admins_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do

      before(:each) do
        put :update_password, provider_id: provider, id: external_user, external_user: { user_attributes: { password: 'password123', password_confirmation: 'passwordxxx' } }
      end

      it 'does not update the user record' do
        expect(external_user.user.updated_at).to eql frozen_time
      end

      it 'renders the change password template' do
        expect(response).to render_template(:change_password)
      end
    end

  end

end
