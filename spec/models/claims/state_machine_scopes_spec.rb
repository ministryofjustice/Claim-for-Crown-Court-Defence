require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  describe 'all available states are scoped' do
    subject { create(:claim) }

    let(:states) { subject.class.state_machine.states.map(&:name) }

    it 'and accessible' do
      states.each do |state|
        subject.update_column(:state, state.to_s)
        expect(subject.class.send(state)).to match_array(subject)
      end
    end
  end

  describe 'custom scopes' do
    let!(:draft_claim) { create(:claim) }
    let!(:submitted_claim) { create(:submitted_claim) }
    let!(:allocated_claim) { create(:allocated_claim) }
    let!(:deleted_claim) { create(:archived_pending_delete_claim) }

    describe '.non_draft' do
      it 'only returns non-draft claims' do
        expect(Claim.non_draft).to match_array([allocated_claim, submitted_claim])
      end
    end
  end
end
