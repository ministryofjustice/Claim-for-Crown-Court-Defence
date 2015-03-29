require 'rails_helper'

RSpec.describe Advocates::ClaimsController, type: :controller do
  let(:advocate) { create(:advocate) }

  before { sign_in advocate }

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
    context 'when advocate signed in' do
      context 'and the input is valid' do
        it 'creates a claim' do
          expect {
            post :create, claim: { additional_information: 'foo' }
          }.to change(Claim, :count).by(1)
        end

        it 'redirects to root url' do
          post :create, claim: { additional_information: 'foo' }
          expect(response).to redirect_to(root_url)
        end

        it 'sets the created claim\'s advocate to the signed in advocate' do
          post :create, claim: { additional_information: 'foo' }
          expect(Claim.first.advocate).to eq(advocate)
        end
      end
    end

    context 'when advocate not signed in' do
      it 'redirects to root url' do
        post :create, claim: { additional_information: 'foo' }
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "PUT #update" do
    subject { create(:claim) }

    it 'updates a claim' do
      put :update, id: subject, claim: { additional_information: 'foo' }
      subject.reload
      expect(subject.additional_information).to eq('foo')
    end

    it 'redirects to root url' do
      put :update, id: subject, claim: { additional_information: 'foo' }
      expect(response).to redirect_to(root_url)
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
