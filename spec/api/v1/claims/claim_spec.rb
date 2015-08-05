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
                          :case_type => 'trial',
                          :case_number => '12345',
                          :first_day_of_trial => Date.today - 100.days,
                          :estimated_trial_length => 10,
                          :actual_trial_length => 9,
                          :trial_concluded_at => Date.today - 91.days,
                          :advocate_category => 'Led junior',
                          :indictment_number => 1234,
                          :offence_id => offence.id,
                          :court_id => court.id,
                          :prosecuting_authority => 'cps'} }

  context 'All claim API endpoints' do
    ALL_CLAIM_ENDPOINTS.each do |endpoint| # for each endpoint
      context 'when sent a non-permitted verb' do
        FORBIDDEN_CLAIM_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it 'should return a status of 405' do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST /api/advocates/claims/validate" do

    def post_to_validate_endpoint
      post VALIDATE_CLAIM_ENDPOINT, claim_params, format: :json
    end

    it "returns 200 and String true for valid request" do
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      expect(json_response).to eq({ "valid" => true })
    end

    it "returns an error when advocate email is invalid" do
      claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to eq("advocate_email is invalid")
    end

    it "returns an error when required param is missing" do
      claim_params.delete(:case_number)
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to eq("case_number is missing")
    end

  end

  describe "POST /api/advocates/claims" do

    def post_to_create_endpoint
      post CREATE_CLAIM_ENDPOINT, claim_params, format: :json
    end

    it "returns 201, claim JSON and creates claim " do
      post_to_create_endpoint
      expect(last_response.status).to eq(201)

      json_response = JSON.parse(last_response.body)

      expect(json_response['id']).not_to be_nil

      expect{ post_to_create_endpoint }.to change { Claim.count }.by(1)
      expect(Claim.find_by(uuid: json_response['id']).uuid).to eq(json_response['id'])
    end

    it "returns 400 and an error when advocate email is invalid" do
      claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
      post_to_create_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to eq("advocate_email is invalid")
    end

     it "returns 400 and errors for several missing required parameter" do
      claim_params.delete(:case_type)
      claim_params.delete(:case_number)
      post_to_create_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to include("case_number is missing")
      expect(error).to include("case_type is missing")
    end

  end

end
