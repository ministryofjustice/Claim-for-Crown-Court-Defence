require 'rails_helper'

RSpec.describe "Cookies", type: :request do

  describe "GET /help/cookies" do
    it "returns http success" do
      get "/help/cookies"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /help/cookie-details" do
    it "returns http success" do
      get "/help/cookie-details"
      expect(response).to have_http_status(:success)
    end
  end
end
