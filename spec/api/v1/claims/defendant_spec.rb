require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Defendant do

  include Rack::Test::Methods

  VALIDATE_ENDPOINT = "api/advocates/defendants/validate"
  CREATE_ENDPOINT = "api/advocates/defendants"

  let!(:claim)             {  create(:claim) }
  let!(:defendant_params)  { {claim_id: 1, first_name: "John", last_name: "Smith", date_of_birth: DateTime.now - 20.years} }

  describe 'POST api/advocates/defendants' do

    def post_to_create_endpoint
      post CREATE_ENDPOINT, defendant_params, format: :json
    end

    context 'when defendant params are valid' do

      it 'returns 201 and creates a new defendant record' do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        expect(Defendant.last.name).to eq 'John Smith'
      end

    end

  end

end