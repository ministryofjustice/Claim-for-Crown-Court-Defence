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
                          :case_number => 'A12345678',
                          :first_day_of_trial => "2015-01-01",
                          :estimated_trial_length => 10,
                          :actual_trial_length => 9,
                          :trial_concluded_at => "2015-01-09",
                          :advocate_category => 'Led junior',
                          :indictment_number => 1234,
                          :offence_id => offence.id,
                          :court_id => court.id } }

  context 'when sending non-permitted verbs' do
    ALL_CLAIM_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_CLAIM_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
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

    it 'valid requests should return 200 and String true' do
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

    it 'missing required params should return 400 and a JSON error array' do
      claim_params.delete(:case_number)
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json[0]['error']).to include("Case number cannot be blank, you must enter a case number")
    end

    it 'returns 400 and JSON error when dates are not in standard JSON format' do
      claim_params[:first_day_of_trial] = '01-01-2015'
      claim_params[:trial_concluded_at] = '09-01-2015'
      claim_params[:trial_fixed_notice_at] = '01-01-2015'
      claim_params[:trial_fixed_at] = '01-01-2015'
      claim_params[:trial_cracked_at] = '01-01-2015'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json).to eq [{"error"=>"first_day_of_trial is not in standard JSON date format (YYYY-MM-DD)"}, {"error"=>"trial_concluded_at is not in standard JSON date format (YYYY-MM-DD)"}, {"error"=>"trial_fixed_notice_at is not in standard JSON date format (YYYY-MM-DD)"}, {"error"=>"trial_fixed_at is not in standard JSON date format (YYYY-MM-DD)"}, {"error"=>"trial_cracked_at is not in standard JSON date format (YYYY-MM-DD)"}]
    end

  end

  describe "POST #{CREATE_CLAIM_ENDPOINT}" do

    def post_to_create_endpoint
      post CREATE_CLAIM_ENDPOINT, claim_params, format: :json
    end

    context "when claim params are valid" do

      it "should create claim, return 201 and claim JSON output including UUID" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Claim.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should create one new claim" do
        expect{ post_to_create_endpoint }.to change { Claim.count }.by(1)
      end

      context "the new claim should" do

        before(:each) {
          post_to_create_endpoint
          @new_claim = Claim.last
        }

        it "have the same attributes as described in params" do
          claim_params.delete(:advocate_email) # because the saved claim record does not have this attribute
          claim_params.each do |attribute, value|
            if @new_claim.send(attribute).class == Date
              claim_params[attribute] = value.to_date # because the sved claim record has Date objects but the param has date strings
            end
            expect(@new_claim.send(attribute).to_s).to eq claim_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it "belong to the advocate whose email was specified in params" do
          expected_owner = User.find_by(email: claim_params[:advocate_email])
          expect(@new_claim.advocate).to eq expected_owner.persona
        end

      end

    end

    context "when claim params are invalid" do

      context "invalid advocate email input" do
        it "should return 400 and a JSON error array when advocate email is invalid" do
          claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to eql("Advocate email is invalid")
        end
      end

      context "missing expected params" do
        it "should return a JSON error array when required model attributes are missing" do
          claim_params.delete(:case_type_id)
          claim_params.delete(:case_number)
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to include("Case type cannot be blank, you must select a case type")
          expect(json[1]['error']).to include("Case number cannot be blank, you must enter a case number")
        end
      end

      context "existing but invalid value" do
        it "should return 400 and JSON error array of model validation errors" do
          claim_params[:estimated_trial_length] = -1
          claim_params[:actual_trial_length] = -1
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to include("Estimated trial length must be a whole number (0 or above)")
          expect(json[1]['error']).to include("Actual trial length must be a whole number (0 or above)")
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          claim_params[:case_type_id] = 1000000000000000000000000000011111
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect(json[0]['error']).to include("out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer")
        end
      end

    end

  end

end
