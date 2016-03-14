require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do
  let(:admin) { create(:case_worker, :admin) }

  before { sign_in admin.user }

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @case_workers' do
      expect(assigns(:case_workers)).to eq(CaseWorker.all)
    end

    it 'assigns @claims' do
      expect(assigns(:claims)).to eq(Claim::BaseClaim.submitted_or_redetermination_or_awaiting_written_reasons.order(last_submitted_at: :asc))
    end

    it 'assigns @allocation' do
      expect(assigns(:allocation)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:claims) { create_list(:submitted_claim, 5) }
    let(:case_worker) { create(:case_worker) }

    let(:allocation_params) {
      {
        case_worker_id: case_worker.id,
        claim_ids: claims.map(&:id)
      }
    }

    before { post :create, allocation: allocation_params }

    context 'when valid' do
      it 'allocates claims to case worker' do
        expect(case_worker.claims).to match_array(claims)
      end

      it 'redirects to new allocation' do
        expect(response).to redirect_to(case_workers_admin_allocations_path(allocation_params))
      end

      it 'tells the user that it was successful and the number of claims allocated' do
        expect(flash[:notice]).to have_content('5 claims allocated to')
      end
    end

    context 'when invalid' do
      let(:allocation_params) {
        {
          claim_ids: claims.map(&:id)
        }
      }

      it 'does not allocate claims to case worker' do
        expect(case_worker.claims).to be_empty
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

    end
  end
end
