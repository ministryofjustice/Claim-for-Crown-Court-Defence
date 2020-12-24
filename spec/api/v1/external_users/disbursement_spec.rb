require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Disbursement do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALL_DISBURSEMENT_ENDPOINTS = [endpoint(:disbursements, :validate), endpoint(:disbursements)]
  FORBIDDEN_DISBURSEMENT_VERBS = [:get, :put, :patch, :delete]

  let(:parsed_body) { JSON.parse(last_response.body) }

  let!(:provider) { create(:provider) }
  let!(:claim) { create(:litigator_claim, source: 'api').reload }
  let!(:disbursement_type) { create(:disbursement_type, :forensic) }

  let!(:params) do
    {
      api_key: provider.api_key,
      claim_id: claim.uuid,
      disbursement_type_id: disbursement_type.id,
      net_amount: 100.01,
      vat_amount: 17.51,
      total: 117.51
    }
  end

  let(:json_error_response) do
    [
      { 'error' => 'Choose a type for the disbursement' },
      { 'error' => 'Enter a net amount for the disbursement' },
      { 'error' => 'Enter a VAT amount for the disbursement' },
      { 'error' => 'Enter a total amount for the disbursement' }
    ].to_json
  end

  context 'sending non-permitted verbs' do
    ALL_DISBURSEMENT_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_DISBURSEMENT_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  # Constant so we can refer to it outside of "it" blocks
  DISBURSEMENT_FIELDS_AND_ERRORS = {
    claim_id: 'Claim cannot be blank',
    disbursement_type_id: 'Choose a type for the disbursement',
    net_amount: 'Enter a net amount for the disbursement',
    vat_amount: 'Enter a VAT amount for the disbursement'
    # total: "Enter a total amount for the disbursement", # SET to zero by model if absent
  }

  describe "POST #{endpoint(:disbursements)}" do
    def post_to_create_endpoint
      post endpoint(:disbursements), params, format: :json
    end

    include_examples 'should NOT be able to amend a non-draft claim'

    context 'when disbursement params are valid' do
      it 'should create disbursement, return 201 and disbursement JSON output including UUID' do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Disbursement.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(Disbursement.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
      end

      it 'should create one new disbursement' do
        expect { post_to_create_endpoint }.to change { Disbursement.count }.by(1)
      end

      it 'should create a new record using the params provided' do
        post_to_create_endpoint
        new_disbursement = Disbursement.last
        expect(new_disbursement.claim_id).to eq claim.id
        expect(new_disbursement.disbursement_type_id).to eq disbursement_type.id
      end
    end

    context 'disbursement_type_unique_code' do
      let(:unique_code) { disbursement_type.unique_code }

      it 'should create a new disbursement record with a disbursement type specified by unique code' do
        params.delete(:disbursement_type_id)
        params.merge!(disbursement_type_unique_code: unique_code)

        post_to_create_endpoint
        expect(last_response.status).to eq 201

        new_disbursement = Disbursement.last
        expect(new_disbursement.claim_id).to eq claim.id
        expect(new_disbursement.disbursement_type_id).to eq disbursement_type.id
        expect(new_disbursement.disbursement_type.unique_code).to eq(unique_code)
      end
    end

    context 'when disbursement params are invalid' do
      context 'invalid API key' do
        let(:valid_params) { params }
        include_examples 'invalid API key create endpoint', exclude: :other_provider
      end

      context 'missing expected params' do
        DISBURSEMENT_FIELDS_AND_ERRORS.each do |field, expected_message|
          it "should give the correct error message when #{field} is blank" do
            params.delete(field)
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect(parsed_body.first).to eq({ 'error' => expected_message })
          end
        end
      end

      context 'mutually exclusive params disbursement_type_id and disbursement_type_unique_code' do
        it 'should return an error if both are provided' do
          params[:disbursement_type_unique_code] = 'XXX'
          expect(params.keys).to include(:disbursement_type_id, :disbursement_type_unique_code)

          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to include('disbursement_type_id, disbursement_type_unique_code are mutually exclusive')
        end
      end

      context 'unexpected error' do
        it 'should return 400 and JSON error array of error message' do
          allow_any_instance_of(Disbursement).to receive(:save!).and_raise(RangeError, 'out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer')
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to include('out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer')
        end
      end

      context 'invalid claim id' do
        it 'should return 400 and a JSON error array' do
          params[:claim_id] = SecureRandom.uuid
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
        end
      end

      context 'malformed claim UUID' do
        it 'should reject invalid uuids' do
          params[:claim_id] = 'any-old-rubbish'
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
        end
      end

      context 'invalid disbursement_type_unique_code' do
        it 'should return 400 and a JSON error if no disbursement type was found' do
          params.delete(:disbursement_type_id)
          params.merge!(disbursement_type_unique_code: 'XXXXX')

          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to eq "[{\"error\":\"Couldn't find DisbursementType\"}]"
        end
      end
    end
  end

  describe "POST #{endpoint(:disbursements, :validate)}" do
    def post_to_validate_endpoint
      post endpoint(:disbursements, :validate), params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      post_to_validate_endpoint
      expect(last_response.status).to eq 200
      json = JSON.parse(last_response.body)
      expect(json).to eq({ 'valid' => true })
    end

    context 'invalid API key' do
      let(:valid_params) { params }
      include_examples 'invalid API key validate endpoint', exclude: :other_provider
    end

    context 'missing expected params' do
      DISBURSEMENT_FIELDS_AND_ERRORS.each do |field, expected_message|
        it "should give the correct error message when #{field} is blank" do
          params.delete(field)
          post_to_validate_endpoint
          expect(last_response.status).to eq 400
          expect(parsed_body.first).to eq({ 'error' => expected_message })
        end
      end
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      params[:claim_id] = SecureRandom.uuid
      post_to_validate_endpoint
      expect(last_response.status).to eq 400
      expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
    end

    context 'AGFS claims' do
      let(:claim) { create(:advocate_claim, source: 'api').reload }
      it 'should return 400 and JSON error array' do
        post_to_validate_endpoint
        expect(last_response.status).to eq 400
        expect(last_response.body).to include '{"error":"Claim is of an inappropriate fee scheme type for the disbursement"}'
      end
    end
  end
end
