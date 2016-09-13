require 'rails_helper'

module Claims
  describe ExternalUserClaimUpdater do
    let(:current_user) { double(User, id: 12345) }

    subject { described_class.new(claim, current_user: current_user) }

    describe '#delete' do
      let(:claim) { create :advocate_claim }

      it 'soft-deletes the claim' do
        subject.delete
        expect(claim.deleted_at).not_to be_nil
      end
    end

    describe '#archive' do
      let(:claim) { create :rejected_claim }

      after(:each) do
        expect(claim.last_state_transition.author_id).to eq(current_user.id)
      end

      it 'archives the claim' do
        subject.archive
        expect(claim.archived_pending_delete?).to be_truthy
      end
    end

    describe '#request_redetermination' do
      let(:claim) { create :part_authorised_claim }

      after(:each) do
        expect(claim.last_state_transition.author_id).to eq(current_user.id)
      end

      it 'sends a redetermination request' do
        subject.request_redetermination
        expect(claim.redetermination?).to be_truthy
      end
    end

    describe '#request_written_reasons' do
      let(:claim) { create :part_authorised_claim }

      after(:each) do
        expect(claim.last_state_transition.author_id).to eq(current_user.id)
      end

      it 'sends a request for reasons' do
        subject.request_written_reasons
        expect(claim.awaiting_written_reasons?).to be_truthy
      end
    end

    describe '#submit' do
      let(:claim) { create :advocate_claim }

      after(:each) do
        expect(claim.last_state_transition.author_id).to eq(current_user.id)
      end

      it 'submits the claim' do
        subject.submit
        expect(claim.submitted?).to be_truthy
      end
    end

    describe '#clone_rejected' do
      let(:claim) { create :rejected_claim }

      it 'clones the claim' do
        expect { subject.clone_rejected }.to change{ Claim::BaseClaim.where(state: 'draft').count }.by(1)
      end

      it 'saves audit attributes in the new draft' do
        draft = subject.clone_rejected
        expect(draft.last_state_transition.author_id).to eq(current_user.id)
      end
    end
  end
end
