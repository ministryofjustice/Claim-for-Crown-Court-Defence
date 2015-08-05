require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Expense do

  include Rack::Test::Methods

  CREATE_EXPENSE_ENDPOINT = "/api/advocates/expenses"
  VALIDATE_EXPENSE_ENDPOINT = "/api/advocates/expenses/validate"

  let!(:claim)                      {  create(:claim).reload }
  let!(:expense_type)               {  create(:expense_type) }
  let!(:valid_params)       { {claim_id: claim.uuid, expense_type_id: expense_type.id, rate: 1, quantity: 2, date: '10 May 2015', location: 'London' }  }
  let!(:invalid_params)     { {claim_id: claim.uuid }                                                                             }

  describe 'POST api/advocates/expenses' do

    def post_to_create_endpoint(params)
      post CREATE_EXPENSE_ENDPOINT, params, format: :json
    end

    context 'when expense params are valid' do

      it 'returns 201 and creates a new expense record' do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
      end

      it 'returns JSON with UUIDs instead of IDs' do
        response = post_to_create_endpoint(valid_params)
        json_response = JSON.parse(response.body)

        expect(json_response['id']).not_to be_nil
        expect(Expense.find_by(uuid: json_response['id']).uuid).to eq(json_response['id'])
        expect(Expense.find_by(uuid: json_response['id']).claim.uuid).to eq(json_response['claim_id'])
      end

    end

    context 'when expense params are invalid' do

      context 'because required values are missing' do
        it 'returns 400 and an appropriate error message in the response body' do
          response = post_to_create_endpoint(invalid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "{\"error\":\"date is missing, expense_type_id is missing, quantity is missing, rate is missing\"}"
        end
      end

    end

  end

  describe 'POST api/advocates/expenses/validate' do

    def post_to_validate_endpoint(params)
      post VALIDATE_EXPENSE_ENDPOINT, params, format: :json
    end

    context 'when params are valid' do
      it 'returns 200' do
        response = post_to_validate_endpoint(valid_params)
        expect(response.status).to eq 200
      end
    end

    context 'when params are invalid' do
      it 'returns 400' do
        response = post_to_validate_endpoint(invalid_params)
        expect(response.status).to eq 400
        expect(response.body).to eq "{\"error\":\"date is missing, expense_type_id is missing, quantity is missing, rate is missing\"}"
      end
    end

  end

end