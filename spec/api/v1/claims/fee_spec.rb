require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  let!(:fee_type)    { create(:fee_type) }
  let!(:claim)       { create(:claim) }
  let!(:fee_params)  { {claim_id: claim.id, fee_type_id: fee_type.id, quantity: 2, rate: 5} }

  describe 'POST api/advocates/fees' do

    def post_to_create_endpoint
      post CREATE_FEE_ENDPOINT, fee_params, format: :json
    end

    context 'when fee params are valid' do

      it 'returns 201 and creates a new defendant record' do
        response = post_to_create_endpoint
        expect(response.status).to eq 201
      end

    end

  end

end