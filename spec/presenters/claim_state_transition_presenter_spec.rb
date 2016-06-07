require 'rails_helper'

RSpec.describe ClaimStateTransitionPresenter do
  let(:claim)      { create(:allocated_claim) }
  let(:subject)    { ClaimStateTransitionPresenter.new(claim.last_state_transition, view) }

  describe "#change" do
    it 'returns a human readable string describing a state change' do
      allow(subject).to receive(:current_user_persona).and_return('CaseWorker')
      expect(subject.transition_message).to eq "Claim allocated"
    end
  end
end
