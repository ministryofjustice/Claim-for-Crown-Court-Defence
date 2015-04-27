require 'rails_helper'

RSpec.describe CaseWorkers::Admin::UsersController, type: :controller do
  let(:admin) { create(:admin) }

  before { sign_in admin.user }

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @users' do
      user = create(:case_worker)
      expect(assigns(:users)).to match_array([admin, user])
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

    it 'assigns @case_worker' do
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

  describe "GET #allocate" do
    subject { create(:case_worker) }

    before { get :allocate, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq(subject)
    end

    it 'assigns @claims' do
      expect(assigns(:claims)).to eq(Claim.all)
    end

    it 'renders the template' do
      expect(response).to render_template(:allocate)
    end
  end

  describe "POST #create" do
    context 'when valid' do
      it 'creates a user' do
        expect {
          post :create, case_worker: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password' }, role: 'case_worker' }
        }.to change(User, :count).by(1)
      end

      it 'redirects to users index' do
        post :create, case_worker: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password' }, role: 'case_worker' }
        expect(response).to redirect_to(case_workers_admin_users_url)
      end
    end

    context 'when invalid' do
      it 'does not create a user' do
        expect {
          post :create, case_worker: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx', role: 'case_worker' }
        }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post :create, case_worker: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx', role: 'case_worker' }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
    subject { create(:case_worker) }

    context 'when valid' do
      before(:each) { put :update, id: subject, case_worker: { role: 'admin' } }

      it 'updates a user' do
        subject.reload
        expect(subject.reload.role).to eq('admin')
      end

      it 'redirects to users index' do
        expect(response).to redirect_to(case_workers_admin_users_url)
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, case_worker: { role: 'foo' } }

      it 'does not update user' do
        subject.reload
        expect(subject.role).to eq('case_worker')
        expect(subject.email).to_not eq('emailexample.com')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'allocating claims' do
      let(:claims) { create_list(:submitted_claim, 3) }

      it 'allocates claims to case worker' do
        put :update, id: subject, case_worker: { claim_ids: [claims.first.id, claims.second.id] }
        subject.reload
        expect(subject.claims).to match_array([claims.first, claims.second])
      end
    end
  end

  describe "DELETE #destroy" do
    subject { create(:case_worker) }

    before { delete :destroy, id: subject }

    it 'destroys the user' do
      expect(CaseWorker.count).to eq(1)
    end

    it 'redirects to admin root url' do
      expect(response).to redirect_to(case_workers_admin_users_url)
    end
  end
end
