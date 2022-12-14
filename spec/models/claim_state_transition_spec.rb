require 'rails_helper'

RSpec.describe ClaimStateTransition do
  it { should belong_to(:claim).class_name('::Claim::BaseClaim') }
  it { should belong_to(:author).class_name('User') }
  it { should belong_to(:subject).class_name('User') }

  describe '.decided_this_month' do
    let(:state) { :rejected }

    context 'when there are no transitions with the "to" provided state' do
      let(:claim) { create(:advocate_claim) }

      before do
        create(:claim_state_transition, claim:, to: 'foo')
        create(:claim_state_transition, claim:, to: 'bar')
      end

      it 'returns 0' do
        expect(described_class.decided_this_month(state)).to eq(0)
      end
    end

    context 'when there are no transitions decided this month' do
      let(:claim) { create(:advocate_claim) }

      before do
        travel_to(3.months.ago) do
          create(:claim_state_transition, claim:, to: 'rejected')
          create(:claim_state_transition, claim:, to: 'bar')
        end
      end

      it 'returns 0' do
        expect(described_class.decided_this_month(state)).to eq(0)
      end
    end

    context 'when there are transitions decided this month' do
      let(:claim) { create(:advocate_claim) }
      let(:other_claim) { create(:advocate_claim) }

      before do
        travel_to(3.months.ago) do
          create(:claim_state_transition, claim:, to: 'rejected')
          create(:claim_state_transition, claim:, to: 'bar')
        end
        create(:claim_state_transition, claim:, to: 'foo')
        create(:claim_state_transition, claim:, to: 'rejected')
        create(:claim_state_transition, claim:, to: 'zzz')
        create(:claim_state_transition, claim:, to: 'rejected')
        create(:claim_state_transition, claim: other_claim, to: 'rejected')
      end

      it 'returns the total claims that transitioned to the provided state for the current month' do
        expect(described_class.decided_this_month(state)).to eq(2)
      end
    end
  end
end
