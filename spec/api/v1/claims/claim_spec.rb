require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Claim do
  include Rack::Test::Methods

  VALIDATE_CLAIM_ENDPOINT = "/api/advocates/claims/validate"
  CREATE_CLAIM_ENDPOINT = "/api/advocates/claims"

  ALL_CLAIM_ENDPOINTS = [VALIDATE_CLAIM_ENDPOINT, CREATE_CLAIM_ENDPOINT]
  FORBIDDEN_CLAIM_VERBS = [:get, :put, :patch, :delete]

  let!(:current_advocate) { create(:advocate) }
  let!(:offence)          { create(:offence)}
  let!(:court)            { create(:court)}
  let!(:claim_params) { { :advocate_email => current_advocate.user.email,
                          :case_type_id => CaseType.find_or_create_by!(name: 'Trial', is_fixed_fee: false).id,
                          :case_number => '12345',
                          :first_day_of_trial => Date.today - 100.days,
                          :estimated_trial_length => 10,
                          :actual_trial_length => 9,
                          :trial_concluded_at => Date.today - 91.days,
                          :advocate_category => 'Led junior',
                          :indictment_number => 1234,
                          :offence_id => offence.id,
                          :court_id => court.id } }

  context 'sending non-permitted verbs' do
    ALL_CLAIM_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_CLAIM_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} on #{endpoint} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST #{VALIDATE_CLAIM_ENDPOINT}" do

    def post_to_validate_endpoint
      post VALIDATE_CLAIM_ENDPOINT, claim_params, format: :json
    end

    it "should return 200 and String true for valid request" do
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ "valid" => true })
    end

    it "should return 400 and JSON error array when advocate email is invalid" do
      claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"

      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)

      expect(json[0]['error']).to eq("Advocate email is invalid")
    end

    it "should return a JSON error array when required model attribute is missing" do
      claim_params.delete(:case_number)
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json[0]['error']).to eq("Case number can't be blank")
    end

  end

  describe "POST #{CREATE_CLAIM_ENDPOINT}" do

    def post_to_create_endpoint
      post CREATE_CLAIM_ENDPOINT, claim_params, format: :json
    end

    context "valid claim JSON input" do
      it "should create claim, return 201 and claim JSON output including UUID" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect{ post_to_create_endpoint }.to change { Claim.count }.by(1)
        expect(Claim.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end
    end

    context "invalid advocate email input" do
      it "should return 400 and a JSON error array when advocate email is invalid" do
        claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
        post_to_create_endpoint
        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json[0]['error']).to eql("Advocate email is invalid")
      end

      context "missing expected params" do
        it "should return a JSON error array when required model attributes are missing" do
          claim_params.delete(:case_type_id)
          claim_params.delete(:case_number)
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to include("Case number can't be blank")
          expect(json[1]['error']).to include("Case type can't be blank")
        end
      end

    end

    context "existing but invalid value" do
      it "should return 400 and JSON error array of model validation errors" do
        claim_params[:estimated_trial_length] = -1
        claim_params[:actual_trial_length] = -1
        post_to_create_endpoint
        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json[0]['error']).to include("Estimated trial length must be greater than or equal to 0")
        expect(json[1]['error']).to include("Actual trial length must be greater than or equal to 0")
      end
    end

    context "unexpected error" do
      it "should return 400 and JSON error array of error message" do
        claim_params[:case_type_id] = 1000000000000000000000000000011111
        post_to_create_endpoint
        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json[0]['error']).to include("PG::NumericValueOutOfRange")
      end
    end

  end

end
