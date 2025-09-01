require 'rails_helper'

RSpec.describe CaseWorkers::Admin::CaseWorkersController do
  let(:admin) { create(:case_worker, :admin) }

  subject { create(:case_worker) }

  before { sign_in admin.user }

  describe 'GET #index' do
    before { get :index }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @case_workers' do
      case_worker = create(:case_worker)
      expect(assigns(:case_workers)).to contain_exactly(admin, case_worker)
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end

    context 'search' do
      before { get :index, params: { search: subject.user.last_name } }

      it 'finds the case workers with specified search criteria' do
        expect(assigns(:case_workers)).to contain_exactly(subject)
      end
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: subject } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end

    render_views
  end

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end

    render_views
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: subject } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @case_worker' do
      expect(assigns(:case_worker)).to eq(subject)
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

    it 'assigns @advocate' do
      expect(assigns(:case_worker)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:change_password)
    end
  end

  # POST #create test converted to requests specs
  # See spec/requests/case_workers/admin/case_workers_spec.rb

  describe 'PUT #update' do
    context 'when valid' do
      before { put :update, params: { id: subject, case_worker: { roles: ['admin'] } } }

      it 'updates a case_worker' do
        subject.reload
        expect(subject.reload.roles).to eq(['admin'])
      end

      it 'redirects to case workers index' do
        expect(response).to redirect_to(case_workers_admin_case_workers_url)
      end

      it { expect(flash[:notice]).to eq('Case worker successfully updated') }
    end

    context 'when invalid' do
      before { put :update, params: { id: subject, case_worker: { roles: ['foo'] } } }

      it 'does not update case worker' do
        subject.reload
        expect(subject.roles).to eq(['case_worker'])
        expect(subject.email).to_not eq('emailexample.com')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'allocating claims' do
      let(:claims) { create_list(:submitted_claim, 3) }

      it 'allocates claims to case worker' do
        put :update, params: { id: subject, case_worker: { claim_ids: [claims.first.id, claims.second.id] } }
        subject.reload
        expect(subject.claims).to contain_exactly(claims.first, claims.second)
      end
    end
  end

  describe 'PUT #update_password' do
    before do
      subject.user.update(password: 'PasswordForTest', password_confirmation: 'PasswordForTest')
      sign_in subject.user # need to sign in again after password change
    end

    context 'when valid' do
      before do
        put :update_password, params: { id: subject, case_worker: { user_attributes: { current_password: 'PasswordForTest', password: 'password5678', password_confirmation: 'password5678' } } }
      end

      it 'redirects to case_worker show action' do
        expect(response).to redirect_to(case_workers_admin_case_worker_path(subject))
      end

      it { expect(flash[:notice]).to eq('Password successfully updated') }
    end

    context 'when mandatory params for case worker are not provided' do
      it 'raises a paramenter missing error' do
        expect {
          put :update_password, params: { id: subject, case_worker: {} }
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context 'when invalid' do
      it 'renders the change password template' do
        put :update_password, params: { id: subject, case_worker: { user_attributes: { foo: 'bar' } } }
        expect(response).to render_template(:change_password)
      end
    end
  end

  describe 'DELETE #destroy' do
    after do
      expect(response).to redirect_to(case_workers_admin_case_workers_url)
    end

    context 'case worker without sent messages' do
      it 'destroys the case worker' do
        delete :destroy, params: { id: subject }
        expect(CaseWorker.active.count).to eq(1)
        expect(CaseWorker.softly_deleted.count).to eq(1)
        expect(subject.reload.deleted_at).not_to be_nil
      end

      it 'redirects to case worker admin root url with notice message' do
        delete :destroy, params: { id: subject }
        expect(flash[:notice]).to eq('Case worker deleted')
      end
    end
  end
end
