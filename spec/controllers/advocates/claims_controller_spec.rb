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
        let(:court) { create(:court) }

        it 'creates a claim' do
          expect {
            post :create, claim: { additional_information: 'foo', court_id: court }
          }.to change(Claim, :count).by(1)
        end

        it 'redirects to claim summary' do
          post :create, claim: { additional_information: 'foo', court_id: court }
          expect(response).to redirect_to(summary_advocates_claim_path(Claim.first))
        end

        it 'sets the created claim\'s advocate to the signed in advocate' do
          post :create, claim: { additional_information: 'foo', court_id: court }
          expect(Claim.first.advocate).to eq(advocate)
        end
      end

      context 'and the input is invalid' do
        it 'does not create a claim' do
          expect {
            post :create, claim: { additional_information: 'foo' }
          }.to_not change(Claim, :count)
        end

        it 'render new template' do
          post :create, claim: { additional_information: 'foo' }
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe "PUT #update" do
    subject { create(:claim) }

    context 'when valid' do
      it 'updates a claim' do
        put :update, id: subject, claim: { additional_information: 'foo' }
        subject.reload
        expect(subject.additional_information).to eq('foo')
      end

      it 'redirects to advocates root url' do
        put :update, id: subject, claim: { additional_information: 'foo' }
        expect(response).to redirect_to(confirmation_advocates_claim_path(subject))
      end
    end

    context 'when invalid' do
      it 'does not update claim' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }
        subject.reload
        expect(subject.additional_information).to be_nil
      end

      it 'renders edit template' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }
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

    it 'redirects to advocates root url' do
      expect(response).to redirect_to(advocates_root_url)
    end
  end
end
