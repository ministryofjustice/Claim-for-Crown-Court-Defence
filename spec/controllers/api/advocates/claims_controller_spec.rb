require 'rails_helper'

RSpec.describe Api::Advocates::ClaimsController, type: :controller do
  let(:advocate)  { create(:advocate)                   }
  let(:new_claim) { build(:claim)                       }
  let(:params)    { {claim: new_claim.attributes}       }
  let(:json)      { JSON.parse(response.body)           }

  before { sign_in advocate }

  describe "GET #index" do
      before do
        create(:claim, advocate: advocate)
        request.accept = 'application/json'
        get :index
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
  end

  describe "POST #create" do
    before do
      @claim_count = Claim.all.count
      request.accept = 'application/json'
      post :create, params
    end

    it 'the prompts a successful response' do
      expect(response).to have_http_status(:success) 
    end

    it "creates a new claim" do
      expect(Claim.all.count).to eq @claim_count + 1
    end

  end

  describe "GET #show" do
    before do
      request.accept = 'application/json'
      create(:claim, advocate: advocate)
    end

    it "displays json corresponding to a specific claim" do
      expect(get :show, {id: Claim.first.id}).to have_http_status(:success)
    end

  end

  describe "GET #edit" do
    before do
      request.accept = 'application/json'
      create(:claim, advocate: advocate)
    end

    it 'returns the record to be edited' do
      expect(get :edit, {id: Claim.first.id}).to have_http_status(:success)
    end

  end

  describe "PUT #update" do
    before do
      request.accept = 'application/json'
      create(:claim, advocate: advocate)
      @claim_to_update = Claim.first
      @claim_to_update.case_type = 'guilty'
    end

    it "updates a record" do
      put :update, id: @claim_to_update.id, claim: @claim_to_update.attributes
      expect(Claim.first.case_type).to eq 'guilty'
    end

  end

  describe "DELETE #destroy" do
    before do
      request.accept = 'application/json'
      create(:claim, advocate: advocate)
    end

    it "destroys a specific record" do
      expect{ delete :destroy, {id: Claim.first.id} }.to change(Claim, :count).by -1
    end
  end

end