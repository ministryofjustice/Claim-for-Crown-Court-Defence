require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypesController, type: :controller do
  let(:external_user) { create(:external_user, :agfs_lgfs_admin) }

  before do
    sign_in(external_user.user)
  end

  include_context 'claim-types helpers'

  describe 'GET #selection' do
    context 'when provider has no available claim types' do
      let(:context_mapper) { instance_double(Claims::ContextMapper) }

      before do
        allow(Claims::ContextMapper).to receive(:new).and_return(context_mapper)
        allow(context_mapper).to receive(:available_comprehensive_claim_types).and_return([])
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
        allow(context_mapper).to receive(:available_comprehensive_claim_types).and_return(%w[invalid_bill_type])
      end

      it 'redirects the user to the claims page with an error' do
        get :selection
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'Invalid bill type selected'
      end
    end

    context 'admin of AGFS and LGFS provider' do
      let(:external_user) { create(:external_user, :agfs_lgfs_admin) }

      it 'assigns bill types based on provider roles' do
        get :selection
        expect(assigns(:available_claim_types)).to match_array(all_claim_types)
      end

      it 'renders the bill type options page' do
        get :selection
        expect(response).to render_template(:selection)
      end
    end

    context 'admin of AGFS provider' do
      let(:external_user) { create(:external_user, :admin, provider: create(:provider, :agfs)) }

      it 'assigns bill types based on provider roles' do
        get :selection
        expect(assigns(:available_claim_types)).to match_array(agfs_claim_types)
      end

      it 'renders the bill type options page' do
        get :selection
        expect(response).to render_template(:selection)
      end
    end

    context 'admin of LGFS provider' do
      let(:external_user) { create(:external_user, :admin, provider: create(:provider, :lgfs)) }

      it 'assigns bill types based on provider roles' do
        get :selection
        expect(assigns(:available_claim_types)).to match_array(lgfs_claim_types)
      end

      it 'renders bill type selection page' do
        get :selection
        expect(response).to render_template(:selection)
      end
    end

    context 'litigator' do
      let(:external_user) { create(:external_user, :litigator) }

      it 'assigns bill types based on external_user roles' do
        get :selection
        expect(assigns(:available_claim_types)).to match_array(lgfs_claim_types)
      end

      it 'renders the bill type selection page' do
        get :selection
        expect(response).to render_template(:selection)
      end
    end
  end

  describe 'POST #chosen' do
    def self.claim_type_redirect_mappings
      { 'agfs' => '/advocates/claims/new',
        'agfs_interim' => '/advocates/interim_claims/new',
        'agfs_supplementary' => '/advocates/supplementary_claims/new',
        'agfs_hardship' => '/advocates/hardship_claims/new',
        'lgfs_final' => '/litigators/claims/new',
        'lgfs_interim' => '/litigators/interim_claims/new',
        'lgfs_transfer' => '/litigators/transfer_claims/new',
        'lgfs_hardship' => '/litigators/hardship_claims/new' }
    end

    context 'with an invalid claim type' do
      before { post :chosen, params: { claim_type: 'invalid' } }

      it 'redirects the user to the claims page with an error' do
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'Invalid bill type selected'
      end
    end

    claim_type_redirect_mappings.each_pair do |claim_type, claim_type_route|
      context "with #{claim_type} claim" do
        before { post :chosen, params: { claim_type: claim_type } }

        it { expect(response).to redirect_to(claim_type_route) }
      end
    end
  end
end
