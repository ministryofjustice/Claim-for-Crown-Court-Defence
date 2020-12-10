require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  describe 'all available states are scoped' do
    subject { create(:advocate_claim) }

    let(:states) { subject.class.state_machine.states.map(&:name) }

    it 'and accessible' do
      states.each do |state|
        subject.update_column(:state, state.to_s)
        expect(subject.class.send(state)).to match_array(subject)
      end
    end
  end

  describe 'custom scopes' do
    let!(:draft_claim) { create(:advocate_claim) }
    let!(:submitted_claim) { create(:submitted_claim) }
    let!(:allocated_claim) { create(:allocated_claim) }
    let!(:deleted_claim) { create(:archived_pending_delete_claim) }
    let!(:redetermination_claim) { create(:redetermination_claim) }
    let!(:awaiting_written_reasons_claim) { create(:awaiting_written_reasons_claim) }

    describe '.non_draft' do
      it 'only returns non-draft claims' do
        expect(Claim::BaseClaim.active.non_draft).to match_array([allocated_claim, submitted_claim, redetermination_claim, awaiting_written_reasons_claim, deleted_claim])
      end
    end

    describe '.submitted_or_redetermination_or_awaiting_written_reasons' do
      it 'only returns submitted or redetermination or awaiting_written_reasons claims' do
        expect(Claim::BaseClaim.active.submitted_or_redetermination_or_awaiting_written_reasons).to match_array([submitted_claim, redetermination_claim, awaiting_written_reasons_claim])
      end
    end

    describe '.non_archived_pending_delete' do
      it 'returns everything but archived_pending_delete cases' do
        expect(Claim::BaseClaim.active.non_archived_pending_delete).to match_array([draft_claim, submitted_claim, allocated_claim, redetermination_claim, awaiting_written_reasons_claim])
      end
    end
  end

  describe 'scoped associations' do
    let(:claim) { create :advocate_claim }

    describe '.archived_claim_state_transitions' do
      it 'only returns transitions to archived state' do
        draft = create :claim_state_transition, claim: claim, to: 'draft'
        submitted = create :claim_state_transition, claim: claim, to: 'submitted'
        allocated = create :claim_state_transition, claim: claim, to: 'allocated'
        rejected = create :claim_state_transition, claim: claim, to: 'rejected'
        authorised = create :claim_state_transition, claim: claim, to: 'authorised'
        redetermination = create :claim_state_transition, claim: claim, to: 'redetermination'
        awaiting_written_reasons = create :claim_state_transition, claim: claim, to: 'awaiting_written_reasons'
        part_authorised = create :claim_state_transition, claim: claim, to: 'part_authorised'
        refused = create :claim_state_transition, claim: claim, to: 'refused'
        archived_pending_delete = create :claim_state_transition, claim: claim, to: 'archived_pending_delete'
        archived_pending_review = create :claim_state_transition, claim: claim, to: 'archived_pending_review'

        claim.reload
        expect(claim.archived_claim_state_transitions).to match_array(
          [
            draft,
            authorised,
            part_authorised,
            rejected,
            refused,
            archived_pending_delete,
            archived_pending_review
          ]
        )
      end
    end
  end
end
