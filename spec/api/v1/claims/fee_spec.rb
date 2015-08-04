require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  VALIDATE_FEE_ENDPOINT = "/api/advocates/fees/validate"

  ALL_FEE_ENDPOINTS = [VALIDATE_FEE_ENDPOINT, CREATE_FEE_ENDPOINT]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  let!(:fee_type)            { create(:fee_type, id: 1) }
  let!(:claim)               { create(:claim) }
  let!(:valid_fee_params)    { {claim_id: claim.id, fee_type_id: fee_type.id, quantity: 3, amount: 10.00 } }
  let!(:invalid_fee_params)  { {claim_id: claim.id} }

  context 'All fee API endpoints' do
    ALL_FEE_ENDPOINTS.each do |endpoint| # for each endpoint
      context 'when sent a non-permitted verb' do
        FORBIDDEN_FEE_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it 'should return a status of 405' do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe 'POST api/advocates/fees' do

    def post_to_create_endpoint
      post CREATE_FEE_ENDPOINT, valid_fee_params, format: :json
    end

    context 'when fee params are valid' do

      it 'returns status of 201' do
        response = post_to_create_endpoint
        expect(response.status).to eq 201
      end

      it 'creates a new fee record with all provided attributes' do
        response = post_to_create_endpoint
        fee = Fee.last
        expect(fee.claim).to eq claim
        expect(fee.fee_type).to eq fee_type
        expect(fee.quantity).to eq 3
        expect(fee.amount).to eq 10.00
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
        invalid_response = post_to_validate_endpoint(invalid_fee_params)
        expect(invalid_response.status).to eq 400
    end

  end

end
