require 'rails_helper'

RSpec.describe CaseWorkers::ClaimsController, type: :controller do
  let(:case_worker) { create(:case_worker) }

  before { sign_in case_worker }

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claims' do
      expect(assigns(:claims)).to eq(Claim.order(created_at: :desc))
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
