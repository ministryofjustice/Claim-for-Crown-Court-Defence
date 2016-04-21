require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypesController, type: :controller, focus: true do

  let(:agfs_lgfs_admin) { create(:external_user, :agfs_lgfs_admin) }
  before { sign_in agfs_lgfs_admin.user }

  describe 'GET #selection' do
    context 'admin of AGFS and LGFS provider' do
      before { get :selection }

      it "should assign claim_types based on provider roles" do
        expect(assigns(:claim_types)).to eql [Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim]
      end
      it "should render claim type options page" do
        expect(response).to render_template(:selection)
      end
    end

    context 'admin of AGFS provider' do
      let!(:agfs_admin) { create(:external_user, :admin, provider: create(:provider, :agfs)) }
      before { sign_in agfs_admin.user }
      before { get :selection }

      it "should assign claim_types based on provider roles" do
        expect(assigns(:claim_types)).to eql [Claim::AdvocateClaim]
      end

      it "should redirect to the new advocate claim form page" do
        expect(response).to redirect_to(new_advocates_claim_path)
      end
    end
    
    context 'admin of LGFS provider' do
      let!(:lgfs_admin) { create(:external_user, :admin, provider: create(:provider, :lgfs)) }
      before { sign_in lgfs_admin.user }
      before { get :selection }

      it "should assign claim_types based on provider roles" do
        expect(assigns(:claim_types)).to eql [Claim::LitigatorClaim, Claim::InterimClaim]
      end

      it "should render claim type options page" do
        expect(response).to render_template(:selection)
      end
    end
  end

  describe 'POST #chosen' do
    context "AGFS claim" do
      before { post :chosen, scheme_chosen: 'agfs'}

      it 'should assign claim_types from params' do
        expect(assigns(:claim_types).first).to eql Claim::AdvocateClaim
      end

      it "should redirect to the new advocate claim form page" do
          expect(response).to redirect_to(new_advocates_claim_path)
      end
    end
  end

end