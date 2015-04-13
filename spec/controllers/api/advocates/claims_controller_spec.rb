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
      puts json.class
      expect(Claim.all.count).to eq @claim_count + 1
    end

  end

end