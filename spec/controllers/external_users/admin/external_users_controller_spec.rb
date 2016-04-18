require 'rails_helper'

RSpec.describe ExternalUsers::Admin::ExternalUsersController, type: :controller do
  let(:provider)  { create(:provider) }
  let(:admin)     { create(:external_user, :admin, provider: provider) }

  subject { create(:external_user, provider: provider) }

  before { sign_in admin.user }

  describe "GET #index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
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

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "GET #change_password" do
    before { get :change_password, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe "POST #create" do
    context 'when valid' do
      it 'creates a external_user' do
        expect {
          post :create, external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith' },
                                    roles: ['advocate'],
                                    supplier_number: 'AB124' }
        }.to change(User, :count).by(1)
      end

      it 'redirects to external_users index' do
        post :create, external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith'},
                                  roles: ['advocate'],
                                  supplier_number: 'XY123'  }
        expect(response).to redirect_to(external_users_admin_external_users_url)
      end
    end

    context 'when invalid' do
      it 'does not create a external_user' do
        expect {
          post :create, external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, roles: ['advocate'] }
        }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post :create, external_user: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, roles: ['advocate'] }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do

    context 'when valid' do
      before(:each) { put :update, id: subject, external_user: { roles: ['admin'] } }

      it 'updates a external_user' do
        subject.reload
        expect(subject.reload.roles).to eq(['admin'])
      end

      it 'redirects to external_users index' do
        expect(response).to redirect_to(external_users_admin_external_users_url)
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, external_user: { roles: ['foo'] } }

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

  describe "PUT #update_password" do

    before do
      subject.user.update(password: 'password', password_confirmation: 'password')
      sign_in subject.user #need to sign in again after password change
    end

    context 'when valid' do
      before(:each) do
        put :update_password, id: subject, external_user: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } }
      end

      it 'redirects to external_user show action' do
        # put :update_password, id: external_user, external_user: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } }
        expect(response).to redirect_to(external_users_admin_external_user_path(subject))
      end
    end

    context 'when invalid' do
      before(:each) { put :update_password, id: subject, external_user: { user_attributes: { } } }

      it 'renders the change password template' do
        expect(response).to render_template(:change_password)
      end
    end
  end

  describe "DELETE #destroy" do


    it 'destroys the external user' do
      subject     # create an additional External user
      expect{
        delete :destroy, id: subject
      }.to change{ExternalUser.count}.by(-1)
    end

    it 'redirects to external_user admin root url' do
      delete :destroy, id: subject
      expect(response).to redirect_to(external_users_admin_external_users_url)
    end
  end
end
