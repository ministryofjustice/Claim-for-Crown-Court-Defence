require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'
require_relative 'shared_examples_for_all'
require_relative 'shared_examples_for_fees'

describe API::V1::ExternalUsers::Fee do

  include Rack::Test::Methods
  include ApiSpecHelper

  CREATE_FEE_ENDPOINT = "/api/external_users/fees"
  VALIDATE_FEE_ENDPOINT = "/api/external_users/fees/validate"

  ALL_FEE_ENDPOINTS = [VALIDATE_FEE_ENDPOINT, CREATE_FEE_ENDPOINT]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  let!(:provider)         { create(:provider) }

  let!(:basic_fee_type)     { create(:basic_fee_type) }
  let!(:misc_fee_type)      { create(:misc_fee_type) }
  let!(:misc_fee_xupl_type) { create(:misc_fee_type, :miupl) }
  let!(:fixed_fee_type)     { create(:fixed_fee_type) }
  let!(:interim_fee_type)   { create(:interim_fee_type) }
  let!(:graduated_fee_type) { create(:graduated_fee_type) }
  let!(:transfer_fee_type)  { create(:transfer_fee_type) }

  let!(:claim)            { create(:claim, source: 'api').reload }
  let(:valid_params)      { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_type.id, quantity: 3, rate: 50.00 } }
  let(:json_error_response) { [ {"error" => "Type of fee not found by ID or Unique Code" } ].to_json }

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

  describe "POST #{CREATE_FEE_ENDPOINT}" do

    def post_to_create_endpoint
      post CREATE_FEE_ENDPOINT, valid_params, format: :json
    end

    include_examples "should NOT be able to amend a non-draft claim"

    context 'when fee params are valid' do

      it "should create fee, return 201 and fee JSON output including UUID" do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Fee::BaseFee.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(Fee::BaseFee.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
      end

      it "should create one new fee" do
        expect{ post_to_create_endpoint }.to change { Fee::BaseFee.count }.by(1)
      end

      it 'should create a new fee record with all provided attributes except amount' do
        post_to_create_endpoint
        fee = Fee::BaseFee.last
        expect(fee.claim_id).to eq claim.id
        expect(fee.fee_type_id).to eq misc_fee_type.id
        expect(fee.quantity).to eq valid_params[:quantity]
        expect(fee.rate).to eq valid_params[:rate]
      end

      context 'fee_type_unique_code' do
        let(:unique_code) { misc_fee_type.unique_code }

        it 'should create a new fee record with a fee type specified by unique code' do
          valid_params.delete(:fee_type_id)
          valid_params.merge!(fee_type_unique_code: unique_code)

          post_to_create_endpoint
          expect(last_response.status).to eq 201

          fee = Fee::BaseFee.last
          expect(fee.claim_id).to eq claim.id
          expect(fee.fee_type_id).to eq misc_fee_type.id
          expect(fee.quantity).to eq valid_params[:quantity]
          expect(fee.rate).to eq valid_params[:rate]
          expect(fee.fee_type.unique_code).to eq(unique_code)
        end
      end

      context 'with fee amount provided' do
        it 'should ignore amount for all fee types that are calculated (all except PPE/NPW)' do
          valid_params.merge!(amount: 155.50)
          post_to_create_endpoint
          fee = Fee::BaseFee.last
          expect(fee.amount).to eq 150.00
        end
      end

      context 'basic fees' do
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, rate: 210.00 } }

        it 'should update, not create, the fee, return 200 and fee JSON output including UUID' do
          post_to_create_endpoint
          expect(last_response.status).to eq 200
          json = JSON.parse(last_response.body)
          expect(json['id']).not_to be_nil
          expect(Fee::BaseFee.find_by(uuid: json['id']).uuid).to eq(json['id'])
          expect(Fee::BaseFee.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
        end

        it 'should update, not create, one basic fee' do
          expect{ post_to_create_endpoint }.to change { Fee::BaseFee.count }.by(0)
        end

        it 'should update the basic fee with the quantity, rate and amount' do
          post_to_create_endpoint
          json = JSON.parse(last_response.body)
          fee = Fee::BaseFee.find_by(uuid: json['id'])
          expect(fee.claim_id).to eq claim.id
          expect(fee.fee_type_id).to eq basic_fee_type.id
          expect(fee.quantity).to eq 1
          expect(fee.rate).to eq 210.00
          expect(fee.amount).to eq 210.00
        end
      end

      context 'basic fees of type case uplift' do
        let!(:fee) { create(:basic_fee, :noc_fee, claim: claim, quantity: 0, rate: 0.0, case_numbers: '') }
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: fee.fee_type_id, quantity: 2, rate: 201.01, case_numbers: 'T20170001,T20170002' } }

        context 'when valid' do
          it 'updates the basic fee with the provided quantity, rate, case_numbers and calculated amount' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::BasicFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.quantity).to eq 2
            expect(fee.rate).to eq 201.01
            expect(fee.amount).to eq 402.02
            expect(fee.case_numbers).to eq 'T20170001,T20170002'
          end
        end
      end

      context 'fixed fees of type case uplift' do
        let!(:fixed_fee_noc_type) { create(:fixed_fee_type, :fxnoc) }
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: fixed_fee_noc_type.id, quantity: 1, rate: 201.01, case_numbers: 'T20170001' } }

        context 'when valid' do
          it 'creates the fixed fee with the provided quantity, rate, case_numbers and calculated amount' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::FixedFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.quantity).to eq 1
            expect(fee.rate).to eq 201.01
            expect(fee.amount).to eq 201.01
            expect(fee.case_numbers).to eq 'T20170001'
          end
        end
      end

      context 'misc fees of type case uplift' do
        context "LGFS fees" do
          let(:claim) { create(:litigator_claim, source: 'api') }
          let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_xupl_type.id, amount: 210, case_numbers: 'T20161234' } }

          it 'creates the misc fee with the provided amount and case numbers' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::MiscFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.fee_type_id).to eq misc_fee_xupl_type.id
            expect(fee.amount).to eq 210.00
            expect(fee.case_numbers).to eq 'T20161234'
          end
        end
      end
    end

    context "fee type specific errors" do
      let!(:valid_params) do
        { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_type.id, quantity: 3, rate: 50.00 }
      end

      it 'THE basic fee should raise basic fee (code BAF) errors' do
        valid_params.delete(:rate)
        valid_params[:fee_type_id] = basic_fee_type.id
        basic_fee_type.update(code: 'BAF') # need to use real basic fee codes to trigger code specific validation and errors
        post_to_create_endpoint
        expect(last_response.status).to eq 400
        expect_error_response("Enter a quantity of 0 to 1 for basic fee",0)
        # NOTE: basic fee should allow 0 rate for claim basic fee at instantiation/creation but not thereafter
        expect_error_response("Enter a valid rate for the basic fee",1)
      end

      it 'uncalculated fees (PPE/NPW) should raise an error when rate provided' do
        valid_params[:fee_type_id] = basic_fee_type.id
        valid_params.merge!(rate: 25)
        basic_fee_type.update(code: 'PPE', calculated: false) # need to use real basic fee codes to trigger code specific validation and errors
        post_to_create_endpoint
        expect(last_response.status).to eq 400
        expect_error_response("Pages of prosecution evidence fees must not have a rate",0)
      end

      context "LGFS fee" do
        let(:claim) { create(:litigator_claim, source: 'api') }
        let!(:valid_params) do
          { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_xupl_type.id, amount: 210.0 }
        end

        it 'should raise error if case numbers are not provided for miscellaneous fee of type Case Uplift' do
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter at least one case number for the miscellaneous fee",0)
        end
      end

      context 'quantity is forbidden' do
        context 'for interim fee disbursement only' do
          let!(:interim_fee_type) { create(:interim_fee_type, :disbursement) }
          let!(:valid_params) { {api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: interim_fee_type.id, quantity: 3, rate: 50.00} }

          it 'should raise error if quantity is provided' do
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response("Do not enter a quantity for the interim fee",0)
          end
        end

        context 'for interim fee warrant only' do
          let!(:interim_fee_type) { create(:interim_fee_type, :warrant) }
          let!(:valid_params) { {api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: interim_fee_type.id, quantity: 3, rate: 50.00} }

          it 'should raise error if quantity is provided' do
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response("Do not enter a quantity for the interim fee",0)
          end
        end
      end

      context 'quantity as decimal or integer' do
        let!(:special_preparation_fee) { create(:misc_fee_type, :spf) }
        let(:parsed_response) { JSON.parse(last_response.body) }

        it 'decimal quantity should raise error if fee type does NOT accept decimal quantities' do
          valid_params[:quantity] = 9.5
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("You must specify a whole number for this type of fee",0)
        end

        it 'decimal quantity should NOT raise error if fee type accepts decimals quantities' do
          valid_params[:fee_type_id] = special_preparation_fee.id
          valid_params[:quantity] = 9.5
          post_to_create_endpoint
          expect(last_response.status).to eq 201
          fee = Fee::BaseFee.find_by(uuid: parsed_response['id'])
          expect(fee.quantity).to eq 9.5
        end
      end

      # NOT exhaustive
      context 'Fee Category' do
        before (:each) { valid_params.delete(:rate) }

        it 'basic fees should raise basic fee errors from translations' do
          valid_params[:fee_type_id] = basic_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter a valid rate for the basic fee",0)
        end

        it 'misc fees should raise misc fee errors from translations' do
          valid_params[:fee_type_id] = misc_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter a rate for the miscellaneous fee",0)
        end

        it 'fixed fees should raise misc fee errors from translations' do
          valid_params[:fee_type_id] = fixed_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter a rate for the fixed fee",0)
        end

        it 'interim fees should raise interim fee errors from translations' do
          valid_params[:fee_type_id] = interim_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter a valid amount for the interim fee",0)
        end

        it 'graduates fees should raise graduated fee errors from translations' do
          valid_params[:fee_type_id] = graduated_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter the graduated fee date",0)
        end

        it 'transfer fees should raise transfer fee errors from translations' do
          valid_params[:fee_type_id] = transfer_fee_type.id
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Enter a valid amount for the transfer fee",0)
        end
      end
    end

    context 'when fee params are invalid' do
      context 'invalid API key' do
        include_examples "invalid API key create endpoint"
      end

      context "missing expected params" do
        it "should return a JSON error array with required model attributes" do
          valid_params.delete(:fee_type_id)
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          json = JSON.parse(last_response.body)
          expect(last_response.body).to eq json_error_response
        end
      end

      context 'mutually exclusive params fee_type_id and fee_type_unique_code' do
        it 'should return an error if both are provided' do
          valid_params[:fee_type_unique_code] = 'XXX'
          expect(valid_params.keys).to include(:fee_type_id, :fee_type_unique_code)

          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to include('fee_type_id, fee_type_unique_code are mutually exclusive')
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          allow(API::Helpers::ApiHelper).to receive(:validate_resource).and_raise(RangeError)
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          result_hash = JSON.parse(last_response.body)
          expect(result_hash).to eq( [ {"error"=>"RangeError"} ] )
        end
      end

      context 'missing claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:claim_id)
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Claim cannot be blank",0)
        end
      end

      context 'invalid claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:claim_id] = SecureRandom.uuid
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response("Claim cannot be blank",0)
        end
      end

      context 'malformed claim UUID' do
        it 'should reject invalid claim id' do
          valid_params[:claim_id] = 'any-old-rubbish'
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          expect_error_response("Claim cannot be blank",0)
        end
      end

    end

  end

  describe "POST #{VALIDATE_FEE_ENDPOINT}" do

    def post_to_validate_endpoint
      post VALIDATE_FEE_ENDPOINT, valid_params, format: :json
    end

    context 'non-basic fees' do
      include_examples "fee validate endpoint"
    end

    context 'basic fees' do
      let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, rate: 210.00 } }
      include_examples "fee validate endpoint"
    end

    context 'when fee params are invalid' do
      context 'invalid API key' do
        include_examples "invalid API key validate endpoint"
      end
    end
  end

end
