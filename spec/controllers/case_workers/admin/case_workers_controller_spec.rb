require 'rails_helper'

RSpec.describe CaseWorkers::Admin::CaseWorkersController, type: :controller do
  let(:admin) { create(:case_worker, :admin) }

  before { sign_in admin.user }


  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @case_workers' do
      case_worker = create(:case_worker)
      expect(assigns(:case_workers)).to match_array([admin, case_worker])
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
      expect(assigns(:case_worker)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end

    render_views

  end

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end

    render_views

  end

  describe "GET #edit" do
    subject { create(:case_worker) }

    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end

    render_views

  end

  describe "GET #allocate" do
    subject { create(:case_worker) }

    before { get :allocate, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to eq(subject)
    end

    it 'assigns @claims' do
      expect(assigns(:claims)).to eq(Claim.non_draft.order(created_at: :asc))
    end

    it 'renders the template' do
      expect(response).to render_template(:allocate)
    end

    render_views

  end

  describe "POST #create" do
    context 'when valid' do
      let(:case_worker_params) {
        {
          case_worker: {
            user_attributes: {
              email: 'foo@foobar.com',
              password: 'password',
              password_confirmation: 'password',
              first_name: 'John',
              last_name: 'Smith'
            },
            role: 'case_worker',
            location_id: create(:location).id
          }
        }
      }

      it 'creates a case_worker' do
        expect {
          post :create, case_worker_params
        }.to change(User, :count).by(1)
      end

      it 'redirects to case workers index' do
        post :create, case_worker_params
        expect(response).to redirect_to(case_workers_admin_case_workers_url)
      end
    end

    context 'when invalid' do
      it 'does not create a case worker' do
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

      it 'updates a case_worker' do
        subject.reload
        expect(subject.reload.role).to eq('admin')
      end

      it 'redirects to case workers index' do
        expect(response).to redirect_to(case_workers_admin_case_workers_url)
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, case_worker: { role: 'foo' } }

      it 'does not update case worker' do
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

    it 'destroys the case worker' do
      expect(CaseWorker.count).to eq(1)
    end

    it 'redirects to case worker admin root url' do
      expect(response).to redirect_to(case_workers_admin_case_workers_url)
    end
  end
end
