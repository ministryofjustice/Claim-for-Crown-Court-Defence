require 'rails_helper'

RSpec.describe Api::Advocates::ClaimsController, type: :controller do
  let(:new_claim)          { build(:claim)                         }
  let(:invalid_new_claim)  { build(:invalid_claim)                 }
  let(:params)             { {claim: new_claim.attributes}         }
  let(:invalid_params)     { {claim: invalid_new_claim.attributes} }

  before do
    http_login
    request.accept = 'application/json'
    @claim_count = Claim.all.count
  end

  describe "POST #create" do
    context 'when validations pass' do
      before do
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
      it 'sets the date of submission' do
        expect(Claim.last.submitted_at).to_not eq nil
      end
    end

    context 'when validations fail' do
      before do
        post :create, invalid_params
      end
      it 'generates a response status of 422 (unprocessable entity)' do
        expect(response.status).to eq 422
      end
      it 'does not create a new claim' do
        expect(Claim.all.count).to eq @claim_count
      end
    end
  end

  def http_login
    name = 'cms_client'
    password = '12345678'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(name,password)
  end

end