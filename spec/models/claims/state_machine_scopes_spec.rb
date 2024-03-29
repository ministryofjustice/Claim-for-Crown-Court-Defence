require 'rails_helper'

RSpec.describe Claims::StateMachine do
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
        expect(Claim::BaseClaim.active.non_draft).to contain_exactly(allocated_claim, submitted_claim, redetermination_claim, awaiting_written_reasons_claim, deleted_claim)
      end
    end

    describe '.submitted_or_redetermination_or_awaiting_written_reasons' do
      it 'only returns submitted or redetermination or awaiting_written_reasons claims' do
        expect(Claim::BaseClaim.active.submitted_or_redetermination_or_awaiting_written_reasons).to contain_exactly(submitted_claim, redetermination_claim, awaiting_written_reasons_claim)
      end
    end

    describe '.non_archived_pending_delete' do
      it 'returns everything but archived_pending_delete cases' do
        expect(Claim::BaseClaim.active.non_archived_pending_delete).to contain_exactly(draft_claim, submitted_claim, allocated_claim, redetermination_claim, awaiting_written_reasons_claim)
      end
    end
  end
end
