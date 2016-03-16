require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypeController, type: :controller, focus: true do

  let!(:agfs_lgfs_admin) { create(:external_user, :agfs_lgfs_admin) }
  before { sign_in agfs_lgfs_admin.user }

  context 'admin of AGFS and LGFS provider'
  describe 'GET #options' do
    before { get :options }
    it "should assign claim_types based on provider roles" do
      expect(assigns(:claim_types).to eql ['agfs','lgfs'])
    end
    it "should redirect to options pages" do
      expect(response).to redirect_to(external_users_claim_options_path)
    end
  end

end