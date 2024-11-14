# frozen_string_literal: true

RSpec.describe 'Court data view' do
  before do
    sign_in user.user
    allow(LAA::Cda::ProsecutionCase).to receive(:search).and_return([])
  end

  let(:claim) { create(:claim) }

  describe 'GET case_workers/claims/<id>/court_data' do
    subject(:show_court_data) { get(case_workers_claim_court_data_index_path(claim)) }

    before { show_court_data }

    context 'when signed in as a case worker' do
      let(:user) { create(:case_worker) }

      it { expect(response).to have_http_status(:ok) }
    end

    context 'when signed in as an external user' do
      let(:user) { create(:external_user) }

      it { expect(response).to redirect_to(external_users_root_path) }
    end
  end
end
