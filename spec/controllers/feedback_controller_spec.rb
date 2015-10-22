require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  let(:advocate) { create(:advocate) }

  before do
    sign_in advocate.user
  end

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
    before do
      post :create
    end

    it "redirects to the users home" do
      expect(response).to redirect_to(advocates_root_url)
    end
  end
end
