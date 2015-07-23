require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Defendant do

  include Rack::Test::Methods

  CREATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants"

  let!(:claim)             {  create(:claim) }
  let!(:defendant_params)  { {claim_id: claim.id, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "10 May 1980"} }

  describe 'POST api/advocates/defendants' do

    def post_to_create_endpoint
      post CREATE_DEFENDANT_ENDPOINT, defendant_params, format: :json
    end

    context 'when defendant params are valid' do

      it 'returns 201 and creates a new defendant record' do
        response = post_to_create_endpoint
        expect(response.status).to eq 201
      end

    end

  end

end