require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @users' do
      user = create(:case_worker)
      expect(assigns(:users)).to eq([user])
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    subject { create(:case_worker) }

    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq(subject)
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

    it 'assigns @user' do
      expect(assigns(:user)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    subject { create(:case_worker) }

    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    it 'creates a user' do
      expect {
        post :create, user: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', role: 'case_worker' }
      }.to change(User, :count).by(1)
    end

    it 'redirects to users index' do
      post :create, user: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', role: 'case_worker' }
      expect(response).to redirect_to(admin_users_url)
    end
  end

  describe "PUT #update" do
    subject { create(:case_worker) }

    before(:each) { put :update, id: subject, user: { email: 'email@example.com' } }

    it 'updates a user' do
      subject.reload
      expect(subject.email).to eq('email@example.com')
    end

    it 'redirects to users index' do
      expect(response).to redirect_to(admin_users_url)
    end
  end

  describe "DELETE #destroy" do
    subject { create(:case_worker) }

    before { delete :destroy, id: subject }

    it 'destroys the user' do
      expect(User.count).to eq(0)
    end

    it 'redirects to advocates root url' do
      expect(response).to redirect_to(admin_users_url)
    end
  end
end
