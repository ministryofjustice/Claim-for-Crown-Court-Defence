require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Defendant do

  include Rack::Test::Methods

  CREATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants"
  VALIDATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants/validate"

  let!(:claim)                     {  create(:claim).reload }
  let!(:valid_params)    { {claim_id: claim.uuid, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "10 May 1980"} }
  let!(:invalid_params)  { {claim_id: claim.uuid} }
  let!(:invalid_claim_id_params)   { {claim_id: SecureRandom.uuid, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "10 May 1980"} }

  describe 'POST api/advocates/defendants' do

    def post_to_create_endpoint(params)
      post CREATE_DEFENDANT_ENDPOINT, params, format: :json
    end

    context 'when defendant params are valid' do

      it 'returns 201 and creates a new defendant record' do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
      end

      it 'returns JSON with UUIDs instead of IDs' do
        response = post_to_create_endpoint(valid_params)
        json_response = JSON.parse(response.body)

        expect(json_response['id']).not_to be_nil
        expect(Defendant.find_by(uuid: json_response['id']).uuid).to eq(json_response['id'])
        expect(Defendant.find_by(uuid: json_response['id']).claim.uuid).to eq(json_response['claim_id'])
      end
    end

    context 'when defendant params are invalid' do

      it 'returns 400 and an appropriate error message in the response body' do
        response = post_to_create_endpoint(invalid_params)
        expect(response.status).to eq 400
        expect(response.body).to eq "{\"error\":\"first_name is missing, last_name is missing, date_of_birth is missing\"}"
      end

    end

  end

  describe "POST /api/advocates/defendants/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_DEFENDANT_ENDPOINT, params, format: :json
    end

    it 'returns 200 when the params are valid' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
    end

    it 'with MISSING PARAMS returns 400 and an appropriate error message' do
      invalid_response = post_to_validate_endpoint(invalid_params)
      expect(invalid_response.status).to eq 400
      expect(invalid_response.body).to eq "{\"error\":\"first_name is missing, last_name is missing, date_of_birth is missing\"}"
    end

    it 'with INVALID CLAIM ID returns 400 and an appropriate error message' do
      invalid_response = post_to_validate_endpoint(invalid_claim_id_params)
      puts invalid_response.body
      expect(invalid_response.status).to eq 400
      expect(invalid_response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
    end
  end
end
