require 'rails_helper'

RSpec.describe Api::Advocates::ClaimsController, type: :controller do
  let(:advocate)  { create(:advocate)                   }
  let(:new_claim) { build(:claim)                       }
  let(:params)    { {claim: new_claim.attributes}       }
  let(:json)      { JSON.parse(response.body)           }

  before do
    sign_in advocate
    request.accept = 'application/json'
    create(:claim, advocate: advocate)
  end

  describe "GET #index" do
      before do
        get :index
      end

      it "generates a response status of 200 (OK)" do
        expect(response.status).to eq 200
      end
      it 'responds with json' do
        expect(response.content_type).to eq 'application/json'
      end
      it 'renders the index view' do
        expect(response).to render_template(:index)
      end
  end

  describe "POST #create" do
    before do
      @claim_count = Claim.all.count
      post :create, params
    end

    it 'generates a response status of 201 (created)' do
      expect(response.status).to eq 201
    end
    it "creates a new claim" do
      expect(Claim.all.count).to eq @claim_count + 1
    end
    it 'responds with json' do
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe "GET #show" do
    before do
      get :show, id: Claim.first.id
    end
    it "generates a response status of 200 (OK)" do
      expect(response.status).to eq 200
    end
    it 'responds with json' do
      expect(response.content_type).to eq 'application/json'
    end
    it 'renders the show view' do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #edit" do
    before do
      get :edit, id: Claim.first.id
    end

    it 'generates a response status of 200 (OK)' do
      expect(response.status).to eq 200
    end
    it 'responds with json' do
      expect(response.content_type).to eq 'application/json'
    end
    it 'renders the edit view' do
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    before do
      @claim_to_update = Claim.first
      @claim_to_update.case_type = 'guilty'
      put :update, id: Claim.first.id, claim: @claim_to_update.attributes
    end

    it 'generates a response status of 200' do
      expect(response.status).to eq 200
    end
    it "updates a record" do
      expect(Claim.first.case_type).to eq 'guilty'
    end
    it 'responds with json' do
      expect(response.content_type).to eq 'application/json'
    end
    it '' do
    end
  end

  describe "DELETE #destroy" do
    before do
      @claims_before_deletion = Claim.all.count
      delete :destroy, {id: Claim.first.id}
    end
    it "removes a single record from the db" do
      expect(Claim.all.count).to eq @claims_before_deletion -1
    end
    it 'responds with json' do
      expect(response.content_type).to eq 'application/json'
    end
  end

end