require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  VALIDATE_FEE_ENDPOINT = "/api/advocates/fees/validate"

  ALL_FEE_ENDPOINTS = [VALIDATE_FEE_ENDPOINT, CREATE_FEE_ENDPOINT]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  let!(:fee_type)            { create(:fee_type, id: 1) }
  let!(:claim)               { create(:claim).reload }
  let!(:valid_params)    { {claim_id: claim.uuid, fee_type_id: fee_type.id, quantity: 3, amount: 10.00 } }
  let!(:invalid_params)  { {claim_id: claim.uuid } }

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

    def post_to_create_endpoint(params)
      post CREATE_FEE_ENDPOINT, params, format: :json
    end

    context 'when fee params are valid' do

      it 'returns status of 201' do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
      end

      it 'creates a new fee record with all provided attributes' do
        response = post_to_create_endpoint(valid_params)
        fee = Fee.last
        expect(fee.claim.id).to eq claim.id
        expect(fee.fee_type).to eq fee_type
        expect(fee.quantity).to eq 3
        expect(fee.amount).to eq 10.00
      end

      it 'returns JSON with UUIDs instead of IDs' do
        response = post_to_create_endpoint(valid_params)
        json_response = JSON.parse(response.body)

        expect(json_response['id']).not_to be_nil
        expect(Fee.find_by(uuid: json_response['id']).uuid).to eq(json_response['id'])
        expect(Fee.find_by(uuid: json_response['id']).claim.uuid).to eq(json_response['claim_id'])
      end

    end

  end

  describe "POST /api/advocates/fees/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_FEE_ENDPOINT, params, format: :json
    end

    it 'returns 200 when the params are valid' do
        response = post_to_validate_endpoint(valid_params)
        expect(response.status).to eq 200
    end

    it 'returns 400 when the params are invalid' do
        invalid_response = post_to_validate_endpoint(invalid_params)
        expect(invalid_response.status).to eq 400
    end

  end

end
