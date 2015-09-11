require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Defendant do

  include Rack::Test::Methods

  CREATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants"
  VALIDATE_DEFENDANT_ENDPOINT = "/api/advocates/defendants/validate"

  ALL_DEFENDANT_ENDPOINTS = [VALIDATE_DEFENDANT_ENDPOINT, CREATE_DEFENDANT_ENDPOINT]
  FORBIDDEN_DEFENDANT_VERBS = [:get, :put, :patch, :delete]

# NOTE: need to specify claim.source as api to ensure defendant model validations applied
  let!(:claim)          {  create(:claim, source: 'api').reload }
  let!(:valid_params)   { {claim_id: claim.uuid, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "1980-05-10"} }
  let!(:invalid_params) { {claim_id: claim.uuid} }
  let(:json_error_response) do
    [
      {'error' => "First name cannot be blank"},
      {'error' => "Last name cannot be blank"},
      {'error' => "Enter valid date of birth"},
    ].to_json
  end

  let!(:invalid_claim_id_params)  { {claim_id: SecureRandom.uuid, first_name: "JohnAPI", last_name: "SmithAPI", date_of_birth: "1980-05-10"} }

  context 'when sending non-permitted verbs' do
    ALL_DEFENDANT_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_DEFENDANT_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe 'POST api/advocates/defendants' do

    def post_to_create_endpoint(params)
      post CREATE_DEFENDANT_ENDPOINT, params, format: :json
    end

    context "when defendant params are valid" do

      it "should create defendant, return 201 and defendant JSON output including UUID" do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq(201)
        json = JSON.parse(response.body)
        expect(json['id']).not_to be_nil
        expect(Defendant.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should create one new defendant" do
        expect{ post_to_create_endpoint(valid_params) }.to change { Defendant.count }.by(1)
      end

      it "should create a new record using the params provided" do
        post_to_create_endpoint(valid_params)
        new_defendant = Defendant.last
        expect(new_defendant.claim_id).to eq claim.id
        expect(new_defendant.first_name).to eq valid_params[:first_name]
        expect(new_defendant.last_name).to eq valid_params[:last_name]
        expect(new_defendant.date_of_birth).to eq valid_params[:date_of_birth].to_date
      end

    end

    context "when defendant params are invalid" do

      context "missing expected params" do
        it "should return a JSON error array with required model attributes" do
          response = post_to_create_endpoint(invalid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq(json_error_response)
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          valid_params[:first_name] = 'a'*256
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          json = JSON.parse(response.body)
          expect(json[0]['error']).to include("PG::StringDataRightTruncation: ERROR:  value too long for type character varying(255)")
        end
      end

      context "malformed claim UUID" do
        it "rejects malformed uuids" do
          valid_params[:claim_id] = 'any-old-rubbish'
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          expect(response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
        end
      end

    end

  end

  describe "POST /api/advocates/defendants/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_DEFENDANT_ENDPOINT, params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq({ "valid" => true })
    end

    it 'missing required params should return 400 and a JSON error array' do
      invalid_response = post_to_validate_endpoint(invalid_params)
      expect(invalid_response.status).to eq 400
      expect(invalid_response.body).to eq(json_error_response)
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      invalid_response = post_to_validate_endpoint(invalid_claim_id_params)
      expect(invalid_response.status).to eq 400
      expect(invalid_response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
    end

    it 'returns 400 and JSON error when dates are not in standard JSON format' do
      invalid_params = valid_params
      invalid_params[:date_of_birth] = '10-05-1980'
      response = post_to_validate_endpoint(invalid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"date_of_birth is not in standard JSON date format (YYYY-MM-DD)\"}]"
    end

  end

end
