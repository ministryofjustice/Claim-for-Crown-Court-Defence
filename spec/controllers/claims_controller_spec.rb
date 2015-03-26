require 'rails_helper'

RSpec.describe ClaimsController, type: :controller do

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claims' do
      expect(assigns(:claims)).to eq(Claim.all)
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    subject { create(:claim) }

    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    subject { create(:claim) }

    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context 'with valid input' do
      let(:advocate) { create(:advocate) }

      it 'creates a claim' do
        expect {
          post :create, claim: { advocate_id: advocate }
        }.to change(Claim, :count).by(1)
      end

      it 'redirects to root url' do
        post :create, claim: { advocate_id: advocate }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'without valid input' do
      it 'does not create a claim' do
        expect {
          post :create, claim: { advocate_id: nil }
        }.to_not change(Claim, :count)
      end

      it 'renders the new template' do
        post :create, claim: { advocate_id: nil }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
    subject { create(:claim) }

    context 'with valid input' do
      let(:advocate) { create(:advocate) }

      it 'updates a claim' do
        put :update, id: subject, claim: { advocate_id: advocate }
        subject.reload
        expect(subject.advocate).to eq(advocate)
      end

      it 'redirects to root url' do
        put :update, id: subject, claim: { advocate_id: advocate }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'without valid input' do
      it 'does not update a claim' do
        put :update, id: subject, claim: { advocate_id: nil }
        subject.reload
        expect(subject.advocate).to_not be_nil
      end

      it 'renders the edit template' do
        put :update, id: subject, claim: { advocate_id: nil }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    subject { create(:claim) }

    before { delete :destroy, id: subject }

    it 'destroys the claim' do
      expect(Claim.count).to eq(0)
    end

    it 'redirects to root url' do
      expect(response).to redirect_to(root_url)
    end
  end
end
