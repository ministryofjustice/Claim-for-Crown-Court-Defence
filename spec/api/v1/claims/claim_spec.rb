require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Claim do
  include Rack::Test::Methods

  # def app
  #   API::V1::Advocates::Claim
  # end

  # describe API::V1::Advocates::Claim do

  VALIDATE_ENDPOINT = "/api/advocates/claims/validate"
  CREATE_ENDPOINT = "/api/advocates/claims"

  let!(:current_advocate) { create(:advocate) }
  let!(:claim_params) { {:advocate_email => current_advocate.user.email, :case_type => 'trial', :case_number => '12345'} }

  describe "POST /api/advocates/claims/validate" do

    def post_to_validate_endpoint
      post VALIDATE_ENDPOINT, claim_params, format: :json
    end

    it "returns 200 and String true for valid request" do
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("true")
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
      post CREATE_ENDPOINT, claim_params, format: :json
    end

    it "returns 201, claim JSON and creates claim " do
      post_to_create_endpoint
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)['id']).not_to be_nil
      expect{ post_to_create_endpoint }.to change { Claim.count }.by(1)
    end

    it "returns 400 and an error when advocate email is invalid" do
      claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
      post_to_create_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to eq("advocate_email is invalid")
    end

     it "returns 400 and errors for each missing required parameter" do
      claim_params.delete(:case_type)
      claim_params.delete(:case_number)
      post_to_create_endpoint
      expect(last_response.status).to eq(400)
      error = JSON.parse(last_response.body)['error']
      expect(error).to include("case_number is missing")
      expect(error).to include("case_type is missing")
    end

  end

  # end
end
