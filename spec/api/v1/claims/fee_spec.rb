require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  VALIDATE_FEE_ENDPOINT = "/api/advocates/fees/validate"

  ALL_FEE_ENDPOINTS = [VALIDATE_FEE_ENDPOINT, CREATE_FEE_ENDPOINT]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  let!(:fee_type)           { create(:fee_type, id: 1) }
  let!(:claim)              { create(:claim, source: 'api').reload }
  let!(:valid_params)       { {claim_id: claim.uuid, fee_type_id: fee_type.id, quantity: 3, amount: 10.09 } }
  let!(:invalid_params)     { {claim_id: claim.uuid } }
  let(:json_error_response)  { "[{\"error\":\"Fee type can't be blank\"}]" }

  context 'sending non-permitted verbs' do
    ALL_FEE_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_FEE_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
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

      it "should create fee, return 201 and expense JSON output including UUID" do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
        json = JSON.parse(response.body)
        expect(json['id']).not_to be_nil
        expect(Fee.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(Fee.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
      end

      it "should create one new fee" do
        expect{ post_to_create_endpoint(valid_params) }.to change { Fee.count }.by(1)
      end

      it 'should create a new fee record with all provided attributes' do
        response = post_to_create_endpoint(valid_params)
        fee = Fee.last
        expect(fee.claim.id).to eq claim.id
        expect(fee.fee_type).to eq fee_type
        expect(fee.quantity).to eq 3
        expect(fee.amount).to eq 10.09
      end

    end

     context 'when fee params are invalid' do

      context "missing expected params" do
        it "should return a JSON error array with required model attributes" do
          response = post_to_create_endpoint(invalid_params)
          expect(response.status).to eq 400
          json = JSON.parse(response.body)
          expect(response.body).to eq json_error_response
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

      context 'missing claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:claim_id)
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
        end
      end

      context 'invalid claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:claim_id] = SecureRandom.uuid
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
        end
      end

    end

  end

  describe "POST /api/advocates/fees/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_FEE_ENDPOINT, params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq({ "valid" => true })
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:fee_type_id)
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq(json_error_response)
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      valid_params[:claim_id] = SecureRandom.uuid
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
    end

  end

end
