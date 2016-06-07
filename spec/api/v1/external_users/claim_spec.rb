require 'rails_helper'
require 'spec_helper'
require_relative 'api_spec_helper'
require_relative 'shared_examples_for_all'

describe API::V1::ExternalUsers::Claim do
  include Rack::Test::Methods
  include ApiSpecHelper

  VALIDATE_CLAIM_ENDPOINT = "/api/external_users/claims/validate".freeze
  CREATE_CLAIM_ENDPOINT = "/api/external_users/claims".freeze

  ALL_CLAIM_ENDPOINTS = [VALIDATE_CLAIM_ENDPOINT, CREATE_CLAIM_ENDPOINT].freeze
  FORBIDDEN_CLAIM_VERBS = [:get, :put, :patch, :delete].freeze

  let!(:provider)       { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:advocate)       { create(:external_user, :advocate, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence)}
  let!(:court)          { create(:court)}
  let!(:valid_params)   {
    {
                          :api_key => provider.api_key,
                          :creator_email => vendor.user.email,
                          :advocate_email => advocate.user.email,
                          :case_type_id => FactoryGirl.create(:case_type, :trial).id,
                          :case_number => 'A12345678',
                          :first_day_of_trial => "2015-01-01",
                          :estimated_trial_length => 10,
                          :actual_trial_length => 9,
                          :trial_concluded_at => "2015-01-09",
                          :advocate_category => 'Led junior',
                          :offence_id => offence.id,
                          :court_id => court.id
}
  }

  describe 'vendor' do
    it 'should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end

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
      post VALIDATE_CLAIM_ENDPOINT, valid_params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      expect(vendor.provider).to eql(advocate.provider)
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ "valid" => true })
    end

    context 'invalid API key' do
      include_examples "invalid API key validate endpoint"

      it "should return 400 and JSON error array when it is an API key from another provider's admin" do
        valid_params[:api_key] = other_provider.api_key
        post_to_validate_endpoint
        expect_error_response("Creator and advocate must belong to the provider")
      end
    end

    it "should return 400 and JSON error array when creator email is invalid" do
      valid_params[:creator_email] = "non_existent_admin@bigblackhole.com"
      post_to_validate_endpoint
      expect_error_response("Creator email is invalid")
    end

    it "should return 400 and JSON error array when advocate email is invalid" do
      valid_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
      post_to_validate_endpoint
      expect_error_response("Advocate email is invalid")
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:case_number)
      post_to_validate_endpoint
      expect_error_response("Enter a case number")
    end

    it 'returns 400 and JSON error when dates are not in acceptable format' do
      valid_params[:first_day_of_trial] = '01-01-2015'
      valid_params[:trial_concluded_at] = '09-01-2015'
      valid_params[:trial_fixed_notice_at] = '01-01-2015'
      valid_params[:trial_fixed_at] = '01-01-2015'
      valid_params[:trial_cracked_at] = '01-01-2015'
      valid_params[:retrial_started_at] = '01-01-2015'
      valid_params[:retrial_concluded_at] = '01-01-2015'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      [
        {"error" => "first_day_of_trial is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "trial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "trial_fixed_notice_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "trial_fixed_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "trial_cracked_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "retrial_started_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"},
        {"error" => "retrial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"}
      ].each do |error|
        expect(json).to include error
      end
    end
  end

  describe "POST #{CREATE_CLAIM_ENDPOINT}" do
    def post_to_create_endpoint
      post CREATE_CLAIM_ENDPOINT, valid_params, format: :json
    end

    context "when claim params are valid" do
      it "should create claim, return 201 and claim JSON output including UUID, but not API key" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Claim::BaseClaim.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should exclude API key, creator email and advocate email from response" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
        expect(json['creator_email']).to be_nil
        expect(json['adovcate_email']).to be_nil
      end

      it "should create one new claim" do
        expect{ post_to_create_endpoint }.to change { Claim::BaseClaim.count }.by(1)
      end

      context "the new claim should" do
        before(:each) {
          post_to_create_endpoint
          @new_claim = Claim::BaseClaim.last
        }

        it "have the same attributes as described in params" do
          valid_params.each do |attribute, value|
            next if [:api_key, :creator_email, :advocate_email].include?(attribute) # because the saved claim record does not have these attribute
            if @new_claim.send(attribute).class == Date
              valid_params[attribute] = value.to_date # because the sved claim record has Date objects but the param has date strings
            end
            expect(@new_claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it "belong to the advocate whose email was specified in params" do
          expected_owner = User.find_by(email: valid_params[:advocate_email])
          expect(@new_claim.external_user).to eq expected_owner.persona
        end
      end
    end

    context "when claim params are invalid" do
      context 'invalid API key' do
        include_examples "invalid API key create endpoint"

        it "should return 400 and JSON error array when it is an API key from another provider" do
          valid_params[:api_key] = other_provider.api_key
          post_to_create_endpoint
          expect_error_response("Creator and advocate must belong to the provider")
        end
      end

      context "invalid email input" do
        it "should return 400 and a JSON error array when advocate email is invalid" do
          valid_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
          post_to_create_endpoint
          expect_error_response("Advocate email is invalid")
        end
        it "should return 400 and a JSON error array when creator email is invalid" do
          valid_params[:creator_email] = "non_existent_creator@bigblackhole.com"
          post_to_create_endpoint
          expect_error_response("Creator email is invalid")
        end
      end

      context "missing expected params" do
        it "should return a JSON error array when required model attributes are missing" do
          valid_params.delete(:case_type_id)
          valid_params.delete(:case_number)
          post_to_create_endpoint
          expect_error_response("Choose a case type", 0)
          expect_error_response("Enter a case number", 1)
        end
      end

      context "existing but invalid value" do
        it "should return 400 and JSON error array of model validation BLANK errors" do
          valid_params[:estimated_trial_length] = -1
          valid_params[:actual_trial_length] = -1
          post_to_create_endpoint
          expect_error_response("Enter a whole number of days for the estimated trial length", 0)
          expect_error_response("Enter a whole number of days for the actual trial length", 1)
        end

        it "should return 400 and JSON error array of model validation INVALID errors" do
          valid_params[:estimated_trial_length] = nil
          valid_params[:actual_trial_length] = nil
          post_to_create_endpoint
          expect_error_response("Enter an estimated trial length", 0)
          expect_error_response("Enter an actual trial length", 1)
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          valid_params[:case_type_id] = 1000000000000000000000000000011111
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          expect_error_response("out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer")
        end
      end
    end
  end
end
