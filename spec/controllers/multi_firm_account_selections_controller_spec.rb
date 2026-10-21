require 'rails_helper'

RSpec.describe MultiFirmAccountSelectionsController do
  let(:primary_user) { create(:external_user, user: build(:user, multi_firm_user: true)).user }
  let(:linked_user) { create(:external_user).user }

  before do
    create(:multi_firm_user_link, user: primary_user, linked_user:)
    session[:multi_firm_primary_user_id] = primary_user.id
  end

  describe 'GET #show' do
    before { get :show }

    it 'responds successfully' do
      expect(response).to have_http_status(:success)
    end

    it 'shows the primary and directly linked accounts' do
      expect(assigns(:accounts)).to contain_exactly(primary_user, linked_user)
    end

    it 'fails closed without a SiLAS-authenticated primary account' do
      session.delete(:multi_firm_primary_user_id)

      get :show

      expect(response).to redirect_to sign_in_path
    end

    it 'allows a signed-in member of the link group to switch accounts' do
      sign_in linked_user

      get :show

      expect(response).to have_http_status(:success)
    end

    it 'rejects a signed-in account outside the link group' do
      sign_in create(:external_user).user

      get :show

      expect(response).to redirect_to sign_in_path
    end
  end

  describe 'POST #create' do
    context 'when selecting a linked account' do
      before { post :create, params: { user_id: linked_user.id } }

      it 'signs in the account' do
        expect(controller.current_user).to eq(linked_user)
      end

      it 'redirects to the external-user home page' do
        expect(response).to redirect_to external_users_root_path
      end
    end

    context 'when selecting the primary account' do
      before { post :create, params: { user_id: primary_user.id } }

      it 'signs in the account' do
        expect(controller.current_user).to eq(primary_user)
      end

      it 'redirects to the external-user home page' do
        expect(response).to redirect_to external_users_root_path
      end
    end

    context 'when selecting an account outside the direct link group' do
      before do
        unrelated_user = create(:external_user).user
        post :create, params: { user_id: unrelated_user.id }
      end

      it 'does not sign in' do
        expect(controller.current_user).to be_nil
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to sign_in_path
      end
    end
  end
end
