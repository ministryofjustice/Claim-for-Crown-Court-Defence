require 'rails_helper'

RSpec.describe ExternalUsers::ClaimTypesController do
  let(:external_user) { create(:external_user, :agfs_lgfs_admin) }

  before do
    sign_in(external_user.user)
  end

  include_context 'claim-types helpers'

  describe 'GET #new' do
    context 'when provider has no available claim types' do
      let(:context_mapper) { instance_double(Claims::ContextMapper) }

      before do
        allow(Claims::ContextMapper).to receive(:new).and_return(context_mapper)
        allow(context_mapper).to receive(:available_comprehensive_claim_types).and_return([])
        get :new
      end

      it { expect(response).to redirect_to(external_users_claims_url) }
      it { expect(controller).to set_flash[:alert].to('No applicable bill types available for user') }
    end

    # OPTIMIZE: check if this flow and functionality is event possible (leftover from when there were fewer claim types?!)
    context 'when provider has only one claim type available' do
      let(:context_mapper) { instance_double(Claims::ContextMapper) }
      let(:claim_class) { Claim::BaseClaim }

      before do
        allow(Claims::ContextMapper).to receive(:new).and_return(context_mapper)
        allow(context_mapper).to receive(:available_comprehensive_claim_types).and_return(%w[agfs])
        get :new
      end

      it { expect(response).to redirect_to('/advocates/claims/new') }
    end

    context 'when provider has agfs and lgs admin role' do
      let(:external_user) { create(:external_user, :agfs_lgfs_admin) }

      before { get :new }

      it { expect(response).to render_template(:new) }
      it { expect(assigns(:available_claim_types)).to match_array(all_claim_types) }
    end

    context 'when provider has agfs admin role' do
      let(:external_user) { create(:external_user, :admin, provider: create(:provider, :agfs)) }

      before { get :new }

      it { expect(response).to render_template(:new) }
      it { expect(assigns(:available_claim_types)).to match_array(agfs_claim_types) }
    end

    context 'when provider has advocate role' do
      let(:external_user) { create(:external_user, :advocate) }

      before { get :new }

      it { expect(response).to render_template(:new) }
      it { expect(assigns(:available_claim_types)).to match_array(agfs_claim_types) }
    end

    context 'when provider has lgfs admin role' do
      let(:external_user) { create(:external_user, :admin, provider: create(:provider, :lgfs)) }

      before { get :new }

      it { expect(response).to render_template(:new) }
      it { expect(assigns(:available_claim_types)).to match_array(lgfs_claim_types) }
    end

    context 'when provider has litigator role' do
      let(:external_user) { create(:external_user, :litigator) }

      before { get :new }

      it { expect(response).to render_template(:new) }
      it { expect(assigns(:available_claim_types)).to match_array(lgfs_claim_types) }
    end
  end

  describe 'POST #create' do
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

    context 'with no claim type' do
      render_views
      before { post :create }

      it { expect(response).to render_template(:new) }
      it { expect(response.body).to have_content('Choose a bill type') }
    end

    context 'with an invalid claim type' do
      render_views
      before { post :create, params: { claim_type: { id: 'invalid' } } }

      it { expect(response).to render_template(:new) }
      it { expect(response.body).to have_content('Choose a valid bill type') }
    end

    claim_type_redirect_mappings.each_pair do |claim_type_id, claim_type_route|
      context "with #{claim_type_id} claim" do
        before { post :create, params: { claim_type: { id: claim_type_id } } }

        it { expect(response).to redirect_to(claim_type_route) }
      end
    end
  end
end
