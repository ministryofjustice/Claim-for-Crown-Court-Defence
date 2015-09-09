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
  let!(:valid_params)               { {claim_id: claim.uuid, expense_type_id: expense_type.id, rate: 1, quantity: 2, location: 'London' }  }
  let!(:invalid_params)             { {claim_id: claim.uuid } }
  let(:json_error_response)   do
    [
      {"error" => "Expense type cannot be blank"},
      {"error" => "Quantity cannot be blank"},
      {"error" => "Rate cannot be blank"}
    ].to_json
  end


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

  describe "POST #{CREATE_EXPENSE_ENDPOINT}" do

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

      it "should create a new record using the params provided" do
        post_to_create_endpoint(valid_params)
        new_expense = Expense.last
        expect(new_expense.claim_id).to eq claim.id
        expect(new_expense.expense_type_id).to eq expense_type.id
        expect(new_expense.rate).to eq valid_params[:rate]
        expect(new_expense.quantity).to eq valid_params[:quantity]
        expect(new_expense.location).to eq valid_params[:location]
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

      context 'invalid claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:claim_id] = SecureRandom.uuid
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
        end
      end

      context "malformed claim UUID" do
        it "should be temporarily handled explicitly (until rails 4.2 upgrade)" do
          valid_params[:claim_id] = 'any-old-rubbish'
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          expect(response.body).to eq "[{\"error\":\"malformed UUID\"}]"
        end
      end

    end

  end

  describe "POST #{VALIDATE_EXPENSE_ENDPOINT}" do

    def post_to_validate_endpoint(params)
      post VALIDATE_EXPENSE_ENDPOINT, params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq({ "valid" => true })
    end

    it 'missing required params should return 400 and a JSON error array' do
      response = post_to_validate_endpoint(invalid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq(json_error_response)
    end
    
    it 'invalid claim id should return 400 and a JSON error array' do
      valid_params[:claim_id] = SecureRandom.uuid
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
    end

  end

end