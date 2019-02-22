require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::SupplementaryClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  SUPPLEMENTARY_CLAIM_ENDPOINT = 'advocates/supplementary'.freeze

  let(:claim_class) { Claim::AdvocateSupplementaryClaim }
  let!(:provider) { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:advocate) { create(:external_user, :advocate, provider: provider) }
  let!(:court) { create(:court)}
  let!(:valid_params) do
    {
      :api_key => provider.api_key,
      :creator_email => vendor.user.email,
      :advocate_email => advocate.user.email,
      :case_number => 'T20191234',
      :advocate_category => 'Leading junior',
      :court_id => court.id
    }
    end

  after(:all) { clean_database }

  # TODO: to be shared with interim_claim_spec.rb (at least)
  describe 'vendor' do
    it 'should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end

  # TODO: to be shared with interim_claim_spec.rb (at least)
  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).all.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        ClaimApiEndpoints.forbidden_verbs.each do |api_verb|
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  # TODO: to be shared with interim_claim_spec.rb (at least)
  describe "POST #{ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).validate}" do
    def post_to_validate_endpoint
      post ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).validate, valid_params, format: :json
    end

    include_examples "invalid API key validate endpoint"

    it 'valid requests should return 200 and String true' do
      expect(vendor.provider).to eql(advocate.provider)
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ "valid" => true })
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
  end

  # TODO: to be shared with interim_claim_spec.rb (at least)
  describe "POST #{ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).create}" do
    def post_to_create_endpoint
      post ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).create, valid_params, format: :json
    end

    context "when claim params are valid" do
      it "should create claim, return 201 and claim JSON output including UUID, but not API key" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(claim_class.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
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
        expect{ post_to_create_endpoint }.to change { claim_class.active.count }.by(1)
      end

      context "the new claim should" do
        let(:claim) { claim_class.active.last }

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

    # TODO: to be shared with interim_claim_spec.rb (at least)
    context "when claim params are invalid" do
      include_examples "invalid API key create endpoint"

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
        before { valid_params.delete(:case_number) }

        it "should return a JSON error array when required model attributes are missing" do
          post_to_create_endpoint
          expect_error_response("Enter a case number")
        end

        it "should not create a new claim" do
          expect{ post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end

      context "existing but invalid value" do
        it "should return 400 and JSON error array of model validation BLANK errors" do
          valid_params[:court_id] = -1
          valid_params[:case_number] = -1
          post_to_create_endpoint
          expect_error_response("Choose a court",0)
          expect_error_response("The case number must be in the format A20161234",1)
        end

        it "should return 400 and JSON error array of model validation INVALID errors" do
          valid_params[:court_id] = nil
          valid_params[:case_number] = nil
          post_to_create_endpoint
          expect_error_response("Choose a court",0)
          expect_error_response("Enter a case number",1)
        end
      end

      context "unexpected error" do
        before do
          allow_any_instance_of(Claim::BaseClaim).to receive(:save!).and_raise(StandardError, 'my unexpected error')
        end

        it "should return 400 and JSON error array of error message" do
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect_error_response("my unexpected error")
        end

        it "should not create a new claim" do
          expect{ post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end
    end
  end
end
