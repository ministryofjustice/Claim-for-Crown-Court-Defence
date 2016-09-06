require 'rails_helper'


module TimedTransitions

  describe BatchTransitioner do

    let(:claim_ids) { [ 22, 878 ] }
    let(:claim_22) { double'Claim 22', state: 'authorised', last_state_transition_time: 2.days.ago }
    let(:claim_878) { double 'Claim 878', state: 'authorised', last_state_transition_time: 2.days.ago }
    let(:transitioner_22) {double 'Transitioner 22' }
    let(:transitioner_878) {double 'Transitioner 878' }

    context 'non dummy' do
      let(:batch_transitioner) { BatchTransitioner.new(dummy: false) }

      it 'only selects claims in correct states' do
        expect(Transitioner).to receive(:candidate_claims_ids).and_return(claim_ids)
        expect(Claim::BaseClaim).to receive(:find).with(22).and_return(claim_22)
        expect(Claim::BaseClaim).to receive(:find).with(878).and_return(claim_878)
        expect(Transitioner).to receive(:new).with(claim_22, false).and_return transitioner_22
        expect(Transitioner).to receive(:new).with(claim_878, false).and_return transitioner_878
        expect(transitioner_22).to receive(:run)
        expect(transitioner_878).to receive(:run)

        batch_transitioner.run
      end
    end

    context 'dummy' do
      let(:batch_transitioner) { BatchTransitioner.new(dummy: true) }

      it 'only selects claims in correct states' do
        expect(Transitioner).to receive(:candidate_claims_ids).and_return(claim_ids)
        expect(Claim::BaseClaim).to receive(:find).with(22).and_return(claim_22)
        expect(Claim::BaseClaim).to receive(:find).with(878).and_return(claim_878)
        expect(Transitioner).to receive(:new).with(claim_22, true).and_return transitioner_22
        expect(Transitioner).to receive(:new).with(claim_878, true).and_return transitioner_878
        expect(transitioner_22).to receive(:run)
        expect(transitioner_878).to receive(:run)

        batch_transitioner.run
      end
    end
  end
end
