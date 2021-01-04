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
    context 'when an invalid scheme is provided' do
      before { post :chosen, params: { claim_type: 'invalid' } }

      it 'redirects the user to the claims page with an error' do
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:alert]).to eq 'Invalid bill type selected'
      end
    end

    context 'AGFS claim' do
      before { post :chosen, params: { claim_type: 'agfs' } }

      it 'should redirect to the new advocate claim form page' do
        expect(response).to redirect_to(new_advocates_claim_path)
      end
    end

    context 'LGFS final claim' do
      before { post :chosen, params: { claim_type: 'lgfs_final' } }

      it 'should redirect to the new litigator final claim form page' do
        expect(response).to redirect_to(new_litigators_claim_path)
      end
    end

    context 'LGFS interim claim' do
      before { post :chosen, params: { claim_type: 'lgfs_interim' } }

      it 'should redirect to the new litigator interim claim form page' do
        expect(response).to redirect_to(new_litigators_interim_claim_path)
      end
    end

    context 'LGFS transfer claim' do
      before { post :chosen, params: { claim_type: 'lgfs_transfer' } }

      it 'should redirect to the new litigator transfer claim form page' do
        expect(response).to redirect_to(new_litigators_transfer_claim_path)
      end
    end
  end
end
