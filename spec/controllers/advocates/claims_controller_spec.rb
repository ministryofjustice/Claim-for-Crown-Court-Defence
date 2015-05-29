require 'rails_helper'

RSpec.describe Advocates::ClaimsController, type: :controller do
  let(:advocate) { create(:advocate) }

  before { sign_in advocate.user }

  describe 'GET #landing' do
    before { get :landing }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the template' do
      expect(response).to render_template(:landing)
    end
  end

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    context 'advocate' do
      before do
        create(:claim, advocate: advocate)
        create(:submitted_claim, advocate: advocate)
        create(:completed_claim, advocate: advocate)
        create(:rejected_claim, advocate: advocate)
      end

      it 'assigns @submitted_claims' do
        expect(assigns(:submitted_claims)).to eq(advocate.reload.claims.submitted.order(created_at: :desc))
      end

      it 'assigns @rejected_claims' do
        expect(assigns(:rejected_claims)).to eq(advocate.reload.claims.rejected.order(created_at: :desc))
      end

      it 'assigns @allocated_claims' do
        expect(assigns(:allocated_claims)).to eq(advocate.reload.claims.allocated.order(created_at: :desc))
      end

      it 'assigns @part_paid_claims' do
        expect(assigns(:part_paid_claims)).to eq(advocate.reload.claims.part_paid.order(created_at: :desc))
      end

      it 'assigns @completed_claims' do
        expect(assigns(:completed_claims)).to eq(advocate.reload.claims.completed.order(created_at: :desc))
      end

      it 'assigns @draft_claims' do
        expect(assigns(:draft_claims)).to eq(advocate.reload.claims.draft.order(created_at: :desc))
      end
    end

    context 'advocate admin' do
      let(:chamber) { create(:chamber) }
      let(:advocate_admin) { create(:advocate, :admin, chamber_id: chamber.id) }

      before do
        create(:claim, advocate: advocate)
        create(:submitted_claim, advocate: advocate)
        create(:completed_claim, advocate: advocate)

        advocate.update_column(:chamber_id, chamber.id)
        create(:claim, advocate: advocate.reload)

        sign_in advocate_admin.user
      end

      it 'assigns @submitted_claims' do
        expect(assigns(:submitted_claims)).to eq(advocate.reload.chamber.claims.submitted.order(created_at: :desc))
      end

      it 'assigns @rejected_claims' do
        expect(assigns(:rejected_claims)).to eq(advocate.reload.chamber.claims.rejected.order(created_at: :desc))
      end

      it 'assigns @allocated_claims' do
        expect(assigns(:allocated_claims)).to eq(advocate.reload.chamber.claims.allocated.order(created_at: :desc))
      end

      it 'assigns @part_paid_claims' do
        expect(assigns(:part_paid_claims)).to eq(advocate.reload.chamber.claims.part_paid.order(created_at: :desc))
      end

      it 'assigns @completed_claims' do
        expect(assigns(:completed_claims)).to eq(advocate.reload.chamber.claims.completed.order(created_at: :desc))
      end

      it 'assigns @draft_claims' do
        expect(assigns(:draft_claims)).to eq(advocate.reload.chamber.claims.draft.order(created_at: :desc))
      end
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
    before { get :edit, id: subject }

    context 'editable claim' do
      subject { create(:claim) }

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

    context 'uneditable claim' do
      subject { create(:allocated_claim) }

      it 'redirects to advocates claims index' do
        expect(response).to redirect_to(advocates_claims_url)
      end
    end
  end

  describe "POST #create" do
    context 'when advocate signed in' do
      context 'and the input is valid' do
        let(:court) { create(:court) }
        let(:offence) { create(:offence) }
        let(:claim_params) do
          {
             additional_information: 'foo',
             court_id: court,
             case_type: 'trial',
             offence_id: offence,
             case_number: '12345',
             advocate_category: 'qc_alone',
             prosecuting_authority: 'cps',
          }
        end

        it 'creates a claim' do
          expect {
            post :create, claim: claim_params
          }.to change(Claim, :count).by(1)
        end

        it 'redirects to claim summary' do
          post :create, claim: claim_params
          expect(response).to redirect_to(summary_advocates_claim_path(Claim.first))
        end

        it 'sets the created claim\'s advocate to the signed in advocate' do
          post :create, claim: claim_params
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
      context 'and draft' do
        it 'updates a claim' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claim summary path' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          expect(response).to redirect_to(summary_advocates_claim_path(subject))
        end
      end

      context 'and submitted' do
        before do
          get :summary, id: subject
          put :update, id: subject, claim: { additional_information: 'foo' }, summary: true
        end

        it 'redirects to the claim confirmation path' do
          expect(response).to redirect_to(confirmation_advocates_claim_path(subject))
        end

        it 'sets the claim to submitted' do
          subject.reload
          expect(subject).to be_submitted
        end

        it 'sets the claim submitted_at' do
          subject.reload
          expect(subject.submitted_at).to_not be_nil
        end
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
    before { delete :destroy, id: subject }

    subject { create(:claim) }

    it 'deletes the claim' do
      expect(Claim.count).to eq(0)
    end

    it "sets the claim's state to 'archived_pending_delete'" do
      expect(subject.reload).to be_archived_pending_delete
    end

    it 'redirects to advocates root url' do
      expect(response).to redirect_to(advocates_claims_url)
    end
  end
end
