require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Claim do
  include Rack::Test::Methods

  def app
    API::V1::Advocates::Claim
  end

  describe API::V1::Advocates::Claim do
    describe "POST /api/advocates/claims/validate" do

      it "returns success" do
        post "/api/advocates/claims/validate", {:advocate_id => 1, :creator_id => 1, :case_type => 'trial', :case_number => 12345}
        expect(last_response.status).to eq(200)
        puts last_response.body
      end

      it "returns false" do
        post "/api/advocates/claims/validate", {:advocate_id => 1, :creator_id => 1, :case_type => 'trial'}
        expect(last_response.status).to eq(400)
        puts JSON.parse(last_response.body)
      end

    end
  end
end
