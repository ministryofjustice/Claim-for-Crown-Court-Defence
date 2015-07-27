require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  VALIDATE_FEE_ENDPOINT = "/api/advocates/fees/validate"
  let!(:fee_type)    { create(:fee_type, id: 2) }
  let!(:claim)       { create(:claim) }
  let!(:valid_fee_params)  { {claim_id: claim.id, fee_type_id: fee_type.id, quantity: 2, rate: 54321} }
  let!(:invalid_fee_params)  { {claim_id: claim.id, fee_type_id: 1, quantity: 2, rate: 54321} }

  describe 'POST api/advocates/fees' do

    def post_to_create_endpoint
      post CREATE_FEE_ENDPOINT, valid_fee_params, format: :json
    end

    context 'when fee params are valid' do

      it 'returns 201 and creates a new fee record' do
        response = post_to_create_endpoint
        expect(response.status).to eq 201
        expect(Fee.last.rate).to eq 54321
      end

    end

  end

  describe "POST /api/advocates/fees/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_FEE_ENDPOINT, params, format: :json
    end

    it 'returns 200 when the params are valid' do
        response = post_to_validate_endpoint(valid_fee_params)
        expect(response.status).to eq 200
    end

    it 'returns 400 when the params are invalid' do
        response = post_to_validate_endpoint(invalid_fee_params)
        expect(response.status).to eq 400
    end

  end

end