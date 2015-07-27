require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Defendant do

  include Rack::Test::Methods

  CREATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants"

  let!(:claim)             {  create(:claim) }
  let!(:valid_defendant_params)  { {claim_id: claim.id, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "10 May 1980"} }
  let!(:invalid_defendant_params)  { {claim_id: claim.id, first_name: "", last_name: "", date_of_birth: ""} }

  describe 'POST api/advocates/defendants' do

    def post_to_create_endpoint(params)
      post CREATE_DEFENDANT_ENDPOINT, params, format: :json
    end

    context 'when defendant params are valid' do

      it 'returns 201 and creates a new defendant record' do
        response = post_to_create_endpoint(valid_defendant_params)
        expect(response.status).to eq 201
      end

    end

    context 'when defendant params are invalid' do

      it 'returns 400 and an appropriate error message in the response body' do
        response = post_to_create_endpoint(invalid_defendant_params)
        expect(response.status).to eq 400
        expect(response.body).to eq "{\"error\":\"first_name cannot be blank, last_name cannot be blank, date_of_birth cannot be blank\"}"
      end

    end

  end

end