require 'rails_helper'

RSpec.describe 'Hardship claims', type: :request do
  let(:advocate) { create(:external_user, :advocate) }
  let(:litigator) { create(:external_user, :litigator) }

  before { seed_case_types }

  describe 'GET #new' do
    context 'when user is not signed in' do
      before do
        get new_advocates_hardship_claim_path
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is a litigator' do
      before do
        sign_in litigator.user
        get new_advocates_hardship_claim_path
      end

      it 'redirects to home page' do
        expect(response).to redirect_to external_users_root_path
      end
    end

    context 'when user is an advocate' do
      before do
        sign_in advocate.user
        get new_advocates_hardship_claim_path
      end

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to be_new_record
      end

      it 'assigns @claim to be an advocate hardship claim' do
        expect(assigns(:claim)).to be_instance_of Claim::AdvocateHardshipClaim
      end

      it 'assigns @case_stages' do
        expect(assigns(:case_stages)).to all(be_a(CaseStage))
      end

      it 'routes to advocates new hardship claim path' do
        expect(request.path).to eq new_advocates_hardship_claim_path
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    let(:claim) { create(:advocate_hardship_claim, external_user: advocate) }

    context 'when user is not signed in' do
      before do
        get edit_advocates_hardship_claim_path(claim)
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is a litigator' do
      before do
        sign_in litigator.user
        get edit_advocates_hardship_claim_path(claim)
      end

      it 'redirects to home page' do
        expect(response).to redirect_to external_users_root_path
      end
    end

    context 'when user is an advocate' do
      before do
        sign_in advocate.user
        get edit_advocates_hardship_claim_path(claim)
      end

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to eql claim
      end

      it 'assigns @case_stages' do
        expect(assigns(:case_stages)).to all(be_a(CaseStage))
      end

      it 'routes to advocates edit hardship claim path' do
        expect(request.path).to eq edit_advocates_hardship_claim_path(claim)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end
  end
end
