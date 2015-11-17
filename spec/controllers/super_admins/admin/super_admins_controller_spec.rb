require 'rails_helper'

RSpec.describe SuperAdmins::Admin::SuperAdminsController, type: :controller do

  let(:super_admin) { create(:super_admin) }

  before(:each) { sign_in super_admin.user }

  describe "GET #show" do
    before { get :show, id: super_admin }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber' do
      expect(assigns(:superadmin)).to super_admin
    end
  end

end
