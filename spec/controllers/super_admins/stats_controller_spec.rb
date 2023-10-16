require 'rails_helper'

RSpec.describe SuperAdmins::StatsController do

  context "when not logged in as Super Admin" do
    it 'redirects the user' do
      get :show
      expect(response).to have_http_status(:found)
    end
  end

  context "when logged in as Super Admin" do
    let(:super_admin) { create(:super_admin) }

    before do
      sign_in(super_admin.user)
      get :show
    end

    it 'uses the show template' do
      expect(response).to render_template(:show)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end
end
