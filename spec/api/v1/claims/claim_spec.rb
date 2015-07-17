require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Claim do
  include Rack::Test::Methods

  def app
    API::V1::Advocates::Claim
  end

  describe API::V1::Advocates::Claim do
    describe "POST /api/advocates/claims/validate" do

      let!(:current_advocate) { create(:advocate) }

      it "valid JSON request returns String true" do
        post "/api/advocates/claims/validate", {:advocate_email => current_advocate.user.email, :case_type => 'trial', :case_number => '12345'}, format: :json
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("true")
      end

      it "invalid JSON request returns error in JSON format" do
        post "/api/advocates/claims/validate", {:advocate_email => current_advocate.user.email, :case_type => 'trial'}, format: :json
        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('"error":"case_number is missing"')
      end

    end
  end
end
