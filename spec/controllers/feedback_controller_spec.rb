require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  describe "GET #new" do
    before do
      get :new
    end

    it 'assigns a new @feedback' do
      expect(assigns(:feedback)).to_not be_nil
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context 'when user signed in' do
      let(:advocate) { create(:advocate) }

      before do
        sign_in advocate.user
      end

      it "redirects to the users home" do
        post :create
        expect(response).to redirect_to(advocates_root_url)
      end
    end

    context 'when no user signed in' do
      it "redirects to the sign in page" do
        post :create
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
