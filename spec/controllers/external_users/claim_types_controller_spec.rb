require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypesController, type: :controller, focus: true do

  let(:agfs_lgfs_admin) { create(:external_user, :agfs_lgfs_admin) }
  before { sign_in agfs_lgfs_admin.user }

  describe 'GET #selection' do
    context 'when provider has no available claim types' do
      let(:context_mapper) { instance_double(Claims::ContextMapper) }

      before do
        allow(Claims::ContextMapper).to receive(:new).and_return(context_mapper)
        allow(context_mapper).to receive(:available_claim_types).and_return([])
      end

      it 'redirects the user to the claims page with an error' do
        get :selection
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'AGFS/LGFS claim type choice incomplete'
      end
    end

    context 'when the only claim type available cannot be managed by the user' do
      let(:context_mapper) { instance_double(Claims::ContextMapper) }
      let(:claim_class) { Claim::BaseClaim }

      before do
        allow(Claims::ContextMapper).to receive(:new).and_return(context_mapper)
        allow(context_mapper).to receive(:available_claim_types).and_return([claim_class])
      end

      it 'redirects the user to the claims page with an error' do
        get :selection
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'Invalid claim types made available to current user'
      end
    end

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
    context 'when an invalid scheme is provided' do
      before { post :chosen, scheme_chosen: 'invalid'}

      it "redirects the user to the claims page with an error" do
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'Invalid claim types made available to current user'
      end
    end

    context "AGFS claim" do
      before { post :chosen, scheme_chosen: 'agfs'}

      it "should redirect to the new advocate claim form page" do
        expect(response).to redirect_to(new_advocates_claim_path)
      end
    end

    context "LGFS final claim" do
      before { post :chosen, scheme_chosen: 'lgfs_final'}

      it "should redirect to the new litigator final claim form page" do
        expect(response).to redirect_to(new_litigators_claim_path)
      end
    end

    context "LGFS interim claim" do
      before { post :chosen, scheme_chosen: 'lgfs_interim'}

      it "should redirect to the new litigator interim claim form page" do
        expect(response).to redirect_to(new_litigators_interim_claim_path)
      end
    end

    context "LGFS transfer claim" do
      before { post :chosen, scheme_chosen: 'lgfs_transfer'}

      it "should redirect to the new litigator transfer claim form page" do
        expect(response).to redirect_to(new_litigators_transfer_claim_path)
      end
    end
  end
end
