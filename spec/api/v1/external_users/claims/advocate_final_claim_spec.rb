require 'rails_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'
require_relative '../shared_examples_for_all'

RSpec.describe API::V1::ExternalUsers::Claims::AdvocateClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let!(:provider)       { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:advocate)       { create(:external_user, :advocate, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence)}
  let!(:court)          { create(:court)}
  let!(:valid_params)   { {
      :api_key => provider.api_key,
      :creator_email => vendor.user.email,
      :advocate_email => advocate.user.email,
      :case_type_id => FactoryBot.create(:case_type, :retrial).id,
      :case_number => 'A20161234',
      :first_day_of_trial => "2015-01-01",
      :estimated_trial_length => 10,
      :actual_trial_length => 9,
      :trial_concluded_at => "2015-01-09",
      :retrial_started_at => "2015-02-01",
      :retrial_concluded_at => "2015-02-05",
      :retrial_actual_length => "4",
      :retrial_estimated_length => "5",
      :retrial_reduction => "true",
      :advocate_category => 'Led junior',
      :offence_id => offence.id,
      :court_id => court.id } }

  after(:all) { clean_database }

  describe 'vendor' do
    it 'should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end

  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(:advocate).all.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        ClaimApiEndpoints.forbidden_verbs.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST #{ClaimApiEndpoints.for(:advocate).validate}" do
    def post_to_validate_endpoint
      post ClaimApiEndpoints.for(:advocate).validate, valid_params, format: :json
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

      it "should return 401 and JSON error array when it is an API key from another provider's admin" do
        valid_params[:api_key] = other_provider.api_key
        post_to_validate_endpoint
        expect_unauthorised_error("Creator and advocate/litigator must belong to the provider")
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
      body = last_response.body
      [
        "first_day_of_trial is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "trial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "trial_fixed_notice_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "trial_fixed_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "trial_cracked_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "retrial_started_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])",
        "retrial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])"
      ].each do |error|
        expect(body).to include(error)
      end
    end
  end

  describe "POST #{ClaimApiEndpoints.for(:advocate).create}" do
    def post_to_create_endpoint
      post ClaimApiEndpoints.for(:advocate).create, valid_params, format: :json
    end

    context "when claim params are valid" do
      it "should create claim, return 201 and claim JSON output including UUID, but not API key" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Claim::AdvocateClaim.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should exclude API key, creator email and advocate email from response" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
        expect(json['creator_email']).to be_nil
        expect(json['advocate_email']).to be_nil
      end

      it "should create one new claim" do
        expect{ post_to_create_endpoint }.to change { Claim::AdvocateClaim.active.count }.by(1)
      end

      context "the new claim should" do
        let(:claim) { Claim::AdvocateClaim.active.last }

        before(:each) {
          post_to_create_endpoint
        }

        it "have the same attributes as described in params" do
          valid_params.each do |attribute, value|
            next if [:api_key, :creator_email, :advocate_email].include?(attribute) # because the saved claim record does not have these attribute
            valid_params[attribute] = value.to_date if claim.send(attribute).class.eql?(Date) # because the saved claim record has Date objects but the param has date strings
            expect(claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it "belong to the advocate whose email was specified in params" do
          expected_owner = User.find_by(email: valid_params[:advocate_email])
          expect(claim.external_user).to eq expected_owner.persona
        end
      end
    end

    context "when claim params are invalid" do
      context 'invalid API key' do
        include_examples "invalid API key create endpoint"

        it "should return 401 and JSON error array when it is an API key from another provider" do
          valid_params[:api_key] = other_provider.api_key
          post_to_create_endpoint
          expect_unauthorised_error("Creator and advocate/litigator must belong to the provider")
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
          expect_error_response("Choose a case type",0)
          expect_error_response("Enter a case number",1)
        end
      end

      context "existing but invalid value" do
        it "should return 400 and JSON error array of model validation BLANK errors" do
          valid_params[:estimated_trial_length] = -1
          valid_params[:actual_trial_length] = -1
          post_to_create_endpoint
          expect_error_response("Enter a whole number of days for the estimated trial length",0)
          expect_error_response("Enter a whole number of days for the actual trial length",1)
        end

        it "should return 400 and JSON error array of model validation INVALID errors" do
          valid_params[:estimated_trial_length] = nil
          valid_params[:actual_trial_length] = nil
          post_to_create_endpoint
          expect_error_response("Enter an estimated trial length",0)
          expect_error_response("Enter an actual trial length",1)
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          valid_params[:case_type_id] = 1000000000000000000000000000011111
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect_error_response("out of range for ActiveModel::Type::Integer")
        end
      end
    end
  end
end
