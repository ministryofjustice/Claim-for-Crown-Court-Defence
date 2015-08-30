require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Expense do

  include Rack::Test::Methods

  CREATE_EXPENSE_ENDPOINT = "/api/advocates/expenses"
  VALIDATE_EXPENSE_ENDPOINT = "/api/advocates/expenses/validate"

  ALL_EXPENSE_ENDPOINTS = [VALIDATE_EXPENSE_ENDPOINT, CREATE_EXPENSE_ENDPOINT]
  FORBIDDEN_EXPENSE_VERBS = [:get, :put, :patch, :delete]

  let!(:claim)                      {  create(:claim, source: 'api').reload }
  let!(:expense_type)               {  create(:expense_type) }
  let!(:valid_params)       { {claim_id: claim.uuid, expense_type_id: expense_type.id, rate: 1, quantity: 2, location: 'London' }  }
  let!(:invalid_params)     { {claim_id: claim.uuid } }
  let(:json_error_response) { "[{\"error\":\"Expense type can't be blank\"},{\"error\":\"Quantity can't be blank\"},{\"error\":\"Quantity is not a number\"},{\"error\":\"Rate can't be blank\"},{\"error\":\"Rate is not a number\"}]" }

  context 'sending non-permitted verbs' do
    ALL_EXPENSE_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_EXPENSE_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe 'POST api/advocates/expenses' do

    def post_to_create_endpoint(params)
      post CREATE_EXPENSE_ENDPOINT, params, format: :json
    end

    context 'when expense params are valid' do

      it "should create expense, return 201 and expense JSON output including UUID" do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
        json = JSON.parse(response.body)
        expect(json['id']).not_to be_nil
        expect(Expense.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(Expense.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
      end

      it "should create one new expense" do
        expect{ post_to_create_endpoint(valid_params) }.to change { Expense.count }.by(1)
      end

    end

    context 'when expense params are invalid' do

      context "missing expected params" do
        it "should return a JSON error array with required model attributes" do
          response = post_to_create_endpoint(invalid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq(json_error_response)
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          valid_params[:quantity] = 1000000000000000000000000
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          json = JSON.parse(response.body)
          expect(json[0]['error']).to include("PG::NumericValueOutOfRange")
        end
      end

    end

  end

  describe 'POST api/advocates/expenses/validate' do

    def post_to_validate_endpoint(params)
      post VALIDATE_EXPENSE_ENDPOINT, params, format: :json
    end

    it 'with valid requests should return 200 and String true' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq({ "valid" => true })
    end

    it 'with missing expected params should return 400 and a JSON error array' do
      response = post_to_validate_endpoint(invalid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq(json_error_response)
    end

    it 'with invalid claim id returns 400 and a JSON error array' do
      valid_params[:claim_id] = SecureRandom.uuid
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
    end

  end

end