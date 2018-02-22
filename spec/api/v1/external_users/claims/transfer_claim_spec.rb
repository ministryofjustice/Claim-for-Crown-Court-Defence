require 'rails_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'
require_relative '../shared_examples_for_all'

describe API::V1::ExternalUsers::Claims::TransferClaim do

  include Rack::Test::Methods
  include ApiSpecHelper

  let!(:provider)       { create(:provider, :lgfs) }
  let!(:other_provider) { create(:provider, :lgfs) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:litigator)      { create(:external_user, :litigator, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence, :miscellaneous)}
  let!(:court)          { create(:court)}
  let!(:valid_params)   { {
      :api_key => provider.api_key,
      :creator_email => vendor.user.email,
      :user_email => litigator.user.email,
      :supplier_number => provider.lgfs_supplier_numbers.first,
      :case_type_id => FactoryBot.create(:case_type, :trial).id,
      :case_number => 'A20161234',
      :offence_id => offence.id,
      :court_id => court.id,
      :case_concluded_at => 1.month.ago.as_json,
      :litigator_type => 'new',
      :elected_case => false,
      :transfer_stage_id => 10,
      :transfer_date => 1.month.ago.as_json,
      :case_conclusion_id => 50 } }

  after(:all) { clean_database }

  describe 'vendor' do
    it 'should belong to same provider as litigator' do
      expect(vendor.provider).to eql(litigator.provider)
    end
  end

  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(:transfer).all.each do |endpoint| # for each endpoint
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


  describe 'POST /api/external_users/claims/transfer/valid' do

    def post_to_validate_endpoint
      post ClaimApiEndpoints.for(:transfer).validate, valid_params, format: :json
    end

    it 'valid requests should return 200 and String true' do
      expect(vendor.provider).to eql(litigator.provider)
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ "valid" => true })
    end

    context 'invalid API key' do

      include_examples 'invalid API key validate endpoint'

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

    it "should return 400 and JSON error array when user email is invalid" do
      valid_params[:user_email] = "non_existent_user@bigblackhole.com"
      post_to_validate_endpoint
      expect_error_response("Litigator email is invalid")
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:case_number)
      post_to_validate_endpoint
      expect_error_response("Enter a case number")
    end
  end

  describe "/api/external_users/claims/transfer" do

    def post_to_create_endpoint
      post ClaimApiEndpoints.for(:transfer).create, valid_params, format: :json
    end

    context "when claim params are valid" do

      it "should create claim, return 201 and claim JSON output including UUID, but not API key" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Claim::TransferClaim.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should exclude API key, creator email and user email from response" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
        expect(json['creator_email']).to be_nil
        expect(json['user_email']).to be_nil
      end

      it "should create one new claim" do
        expect{ post_to_create_endpoint }.to change { Claim::TransferClaim.active.count }.by(1)
      end

      it "should create one transfer detail" do
        expect{ post_to_create_endpoint }.to change { Claim::TransferDetail.count }.by(1)
      end

      context "the new claim should" do

        before(:each) {
          post_to_create_endpoint
          @new_claim = Claim::TransferClaim.active.last
        }

        it "have the same attributes as described in params" do
          valid_params.each do |attribute, value|
            next if [:api_key, :creator_email, :user_email].include?(attribute) # because the saved claim record does not have these attribute
            if @new_claim.send(attribute).class == Date
              valid_params[attribute] = value.to_date # because the sved claim record has Date objects but the param has date strings
            end
            expect(@new_claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it "belong to the litigator whose email was specified in params" do
          expected_owner = User.find_by(email: valid_params[:user_email])
          expect(@new_claim.external_user).to eq expected_owner.persona
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
        it "should return 400 and a JSON error array when user email is invalid" do
          valid_params[:user_email] = "non_existent_user@bigblackhole.com"
          post_to_create_endpoint
          expect_error_response("Litigator email is invalid")
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
          valid_params.delete(:case_concluded_at)
          valid_params.delete(:elected_case)
          post_to_create_endpoint
          expect_error_response("Choose the elected case status",0)
          expect_error_response("Do not enter a case conclusion",1)
          expect_error_response("Check the case conclusion in combination with other transfer details",2)
          expect_error_response("Check combination of transfer details",3)
        end
      end

      context "existing but invalid value" do
        it "should return 400 and JSON error array of model validation BLANK errors" do
          valid_params[:litigator_type] = 'invalid'
          post_to_create_endpoint
          expect_error_response("litigator_type does not have a valid value",0)
        end

        it "should return 400 and JSON error array of model validation INVALID errors" do
          valid_params[:case_number] = nil
          valid_params[:case_concluded_at] = 1.month.from_now.as_json
          post_to_create_endpoint
          expect_error_response("Enter a case number for example A20161234",0)
          expect_error_response("Check the date case concluded",1)
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
