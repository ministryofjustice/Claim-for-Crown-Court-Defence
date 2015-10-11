require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_fees'

describe API::V1::Advocates::Fee do

  include Rack::Test::Methods

  CREATE_FEE_ENDPOINT = "/api/advocates/fees"
  VALIDATE_FEE_ENDPOINT = "/api/advocates/fees/validate"

  ALL_FEE_ENDPOINTS = [VALIDATE_FEE_ENDPOINT, CREATE_FEE_ENDPOINT]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  let!(:basic_fee_type)     { FactoryGirl.create(:fee_type, :basic) }
  let!(:misc_fee_type)      { FactoryGirl.create(:fee_type, :misc) }
  let!(:claim)              { FactoryGirl.create(:claim, source: 'api').reload }
  let!(:valid_params)       { {claim_id: claim.uuid, fee_type_id: misc_fee_type.id, quantity: 3, amount: 150.00 } }
  let!(:invalid_params)     { {claim_id: claim.uuid } }
  let(:json_error_response) { [ {"error" => "Fee type cannot be blank" } ].to_json }

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

      it "should create fee, return 201 and fee JSON output including UUID" do
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
        post_to_create_endpoint(valid_params)
        fee = Fee.last
        expect(fee.claim_id).to eq claim.id
        expect(fee.fee_type_id).to eq misc_fee_type.id
        expect(fee.quantity).to eq valid_params[:quantity]
        expect(fee.amount).to eq valid_params[:amount]
      end


      context 'basic fees' do

        let!(:valid_params) { {claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, amount: 210.00 } }

        it 'should update, not create, the fee, return 200 and fee JSON output including UUID' do
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['id']).not_to be_nil
          expect(Fee.find_by(uuid: json['id']).uuid).to eq(json['id'])
          expect(Fee.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
        end

        it 'should update, not create, one basic fee' do
          expect{ post_to_create_endpoint(valid_params) }.to change { Fee.count }.by(0)
        end

        it 'should update the basic fee with the quantity and amount' do
          response = post_to_create_endpoint(valid_params)
          json = JSON.parse(response.body)
          fee = Fee.find_by(uuid: json['id'])
          expect(fee.claim_id).to eq claim.id
          expect(fee.fee_type_id).to eq basic_fee_type.id
          expect(fee.quantity).to eq 1
          expect(fee.amount).to eq 210.00
        end
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
          allow(API::V1::ApiHelper).to receive(:validate_resource).and_raise(RangeError)
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          result_hash = JSON.parse(response.body)
          expect(result_hash).to eq( [ {"error"=>"RangeError"} ] )
        end
      end

      context 'missing claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:claim_id)
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
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

      context 'malformed claim UUID' do
        it 'should reject invalid claim id' do
          valid_params[:claim_id] = 'any-old-rubbish'
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          expect(response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
        end
      end

    end

  end

  describe 'POST /api/advocates/fees/validate' do

    def post_to_validate_endpoint(params)
      post VALIDATE_FEE_ENDPOINT, params, format: :json
    end

    context 'non-basic fees' do
      include_examples "fee validate endpoint"
    end

    context 'basic fees' do
      let!(:valid_params) { {claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, amount: 210.00 } }
      include_examples "fee validate endpoint"
    end

  end

end
