require 'rails_helper'


module TimedTransitions
  describe Transitioner do
    let(:claim) { double Claim }

    describe '.candidate_states' do
      it 'should return an array of source states for timed transitions' do
        expect(Transitioner.candidate_states).to eq([
          :authorised,
          :part_authorised,
          :refused,
          :rejected,
          :archived_pending_delete
        ])
      end
    end

    describe '.candidate_claims' do
      it 'should generate the correct sql' do
        expect(Transitioner.candidate_claims.to_sql).to eq(
          %q<SELECT "claims".* FROM "claims" WHERE (state in ('authorised','part_authorised','refused','rejected','archived_pending_delete'))>
        )
      end
    end

    describe '.process' do
      it 'should not call archive if last state change less than 60 days ago' do
        claim = double Claim
        expect(claim).to receive(:last_state_transition_time).and_return(59.days.ago)
        expect(claim).to receive(:state).and_return('authorised')
        transitioner = Transitioner.new(claim)
        expect(transitioner).not_to receive(:archive)
        transitioner.run
      end

      it 'should call archive if last state change more than 60 days ago' do
        expect(claim).to receive(:last_state_transition_time).and_return(61.days.ago)
        expect(claim).to receive(:state).and_return('authorised')
        transitioner = Transitioner.new(claim)
        expect(transitioner).to receive(:archive)
        transitioner.run
      end

      it 'should not call destroy if last state change less than 60 days ago' do
        expect(claim).to receive(:last_state_transition_time).and_return(59.days.ago)
        expect(claim).to receive(:state).and_return('archived_pending_delete')
        transitioner = Transitioner.new(claim)
        expect(transitioner).not_to receive(:destroy)
        transitioner.run
      end

      it 'should call destroy if last state change more than 60 days ago' do
        expect(claim).to receive(:last_state_transition_time).and_return(61.days.ago)
        expect(claim).to receive(:state).and_return('archived_pending_delete')
        transitioner = Transitioner.new(claim)
        expect(transitioner).to receive(:destroy)
        transitioner.run
      end
    end

    describe '#archive' do
      it 'should call archive pending delete on the claim' do
        transitioner = Transitioner.new(claim)
        expect(claim).to receive(:archive_pending_delete!)
        transitioner.send(:archive)
      end
    end

    describe '#destroy' do
      it 'should call destroy on the claim' do
        transitioner = Transitioner.new(claim)
        expect(claim).to receive(:destroy)
        transitioner.send(:destroy)
      end
    end
  end
end