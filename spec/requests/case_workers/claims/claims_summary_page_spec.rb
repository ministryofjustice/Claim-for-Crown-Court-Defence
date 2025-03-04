RSpec.describe 'Sub Navigation Tab' do
  before do
    sign_in case_worker.user
    case_worker_claim
  end

  let(:case_worker) { create(:case_worker) }
  let(:claim) { create(:claim, :submitted) } # Ensure claim exists
  let(:case_worker_claim) { create(:case_worker_claim, case_worker:, claim:) }

  describe 'GET /case_workers/claims/:id' do
    subject(:show_claim_information) { get(case_workers_claim_path(claim.id)) } # Use claim.id explicitly

    context 'when signed in as a case worker' do
      before { show_claim_information }

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'defaults to the claim information tab' do
        expect(response.body).to include('Basic claim information')
      end
    end

    context 'when claim status tab is clicked' do
      before { get case_workers_claim_path(claim.id, tab: 'status') }

      it 'displays claim status page' do
        expect(response.body).to include('Assessment summary')
      end
    end

    context 'when claim information tab is clicked' do
      before { get case_workers_claim_path(claim.id, tab: 'information') }

      it 'returns to the information page' do
        expect(response.body).to include('Basic claim information')
      end
    end
  end
end
