require 'rails_helper'

RSpec.describe CaseWorkers::ClaimsController, type: :controller do
  let!(:case_worker) { create(:case_worker) }
  let!(:claims) { create_list(:submitted_claim, 5) }
  let!(:other_claim) { create(:submitted_claim) }

  before do
    claims.each do |claim|
      claim.case_workers << case_worker
    end

    sign_in case_worker.user
  end

  describe "GET #index" do
    let(:tab) { nil }
    let(:search) { nil }
    before { get :index, tab: tab, search: search }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    context 'current claims' do
      it 'assigns submitted @claims' do
        expect(assigns(:claims)).to eq(case_worker.claims.submitted)
      end
    end

    context 'completed claims' do
      let(:tab) { 'completed' }

      it 'assigns completed @claims' do
        expect(assigns(:claims)).to eq(case_worker.claims.completed)
      end
    end

    context 'search' do
      let(:search) { '12345' }
      before do
        create(:defendant, claim_id: case_worker.claims.first.id, maat_reference: '12345')
      end

      it 'finds the claims with MAAT reference "12345"' do
        expect(assigns(:claims)).to eq([case_worker.claims.first])
      end
    end

    it 'only includes claims associated with the case worker' do
      expect(assigns(:claims)).to match_array(claims)
    end

    it 'does not include claim not assigned to case worker' do
      expect(assigns(:claims)).to_not include(other_claim)
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    subject { create(:claim) }

    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end
  end
end
