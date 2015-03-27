require 'rails_helper'

RSpec.describe Advocates::DashboardController, type: :controller do
  let(:advocate) { create(:advocate) }

  before do
    sign_in advocate
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
