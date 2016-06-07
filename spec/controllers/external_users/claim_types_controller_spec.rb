require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypesController, type: :controller, focus: true do
  let(:agfs_lgfs_admin) { create(:external_user, :agfs_lgfs_admin) }
  before { sign_in agfs_lgfs_admin.user }
  before { allow(Settings).to receive(:allow_lgfs_interim_fees?).and_return true }
  before { allow(Settings).to receive(:allow_lgfs_transfer_fees?).and_return true }

  describe 'GET #selection' do
    context 'admin of AGFS and LGFS provider' do
      before { get :selection }

      it "should assign claim_types based on provider roles" do
        expect(assigns(:claim_types)).to match_array [Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
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
        expect(assigns(:claim_types)).to match_array [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
      end

      it "should render claim type options page" do
        expect(response).to render_template(:selection)
      end
    end

    context 'litigator' do
      let!(:litigator) { create(:external_user, :litigator) }
      before { sign_in litigator.user }
      before { get :selection }

      it "should assign claim_types based on external_user roles" do
        expect(assigns(:claim_types)).to match_array [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
      end

      it 'should render claim type options' do
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

    context "LGFS final claim" do
      before { post :chosen, scheme_chosen: 'lgfs_final'}

      it 'should assign claim_types to be a litigator final claim' do
        expect(assigns(:claim_types).first).to eql Claim::LitigatorClaim
      end

      it "should redirect to the new litigator final claim form page" do
        expect(response).to redirect_to(new_litigators_claim_path)
      end
    end

    context "LGFS interim claim" do
      before { post :chosen, scheme_chosen: 'lgfs_interim'}

      it 'should assign claim_types to be an litigator interim claim' do
        expect(assigns(:claim_types).first).to eql Claim::InterimClaim
      end

      it "should redirect to the new litigator interim claim form page" do
        expect(response).to redirect_to(new_litigators_interim_claim_path)
      end
    end

    context "LGFS transfer claim" do
      before { post :chosen, scheme_chosen: 'lgfs_transfer'}

      it 'should assign claim_types to be an litigator transfer claim' do
        expect(assigns(:claim_types).first).to eql Claim::TransferClaim
      end

      it "should redirect to the new litigator transfer claim form page" do
        expect(response).to redirect_to(new_litigators_transfer_claim_path)
      end
    end
  end
end
