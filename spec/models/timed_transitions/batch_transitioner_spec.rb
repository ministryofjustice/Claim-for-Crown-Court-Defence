require 'rails_helper'

module TimedTransitions
  describe BatchTransitioner do
    let(:claim_ids) { [22, 878] }
    let(:claim_22) { double'Claim 22', state: 'authorised', last_state_transition_time: 2.days.ago }
    let(:claim_878) { double 'Claim 878', state: 'authorised', last_state_transition_time: 2.days.ago }
    let(:transitioner_22) { double('Transitioner 22', success?: true) }
    let(:transitioner_878) { double('Transitioner 878', success?: true) }

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

    context 'enforces a limit if provided' do
      let(:batch_transitioner) { BatchTransitioner.new(limit: 1) }

      it 'after the given limit it stops processing claims' do
        expect(Transitioner).to receive(:candidate_claims_ids).and_return(claim_ids)
        expect(Claim::BaseClaim).to receive(:find).with(22).and_return(claim_22)
        expect(Claim::BaseClaim).not_to receive(:find).with(878)
        expect(Transitioner).to receive(:new).with(claim_22, false).and_return transitioner_22
        expect(Transitioner).not_to receive(:new).with(claim_878, false)
        expect(transitioner_22).to receive(:run)

        expect(batch_transitioner).to receive(:increment_counter).once.and_call_original
        batch_transitioner.run
        expect(batch_transitioner.transitions_counter).to eq(1)
      end
    end

    context 'logging' do
      subject(:batch_transitioner) { BatchTransitioner.new(limit: 10000) }

      it 'write to log file using LogStuff' do
        freeze_time do
          expect(LogStuff).to receive(:info)
            .with('TimedTransitions::BatchTransitioner',
                  environment: 'test',
                  limit: 10000,
                  started_at: DateTime.current,
                  claims_processed: nil,
                  finished_at: nil,
                  seconds_taken: nil).exactly(:once)

          expect(LogStuff).to receive(:info)
            .with('TimedTransitions::BatchTransitioner',
                  environment: 'test',
                  limit: 10000,
                  started_at: DateTime.current,
                  claims_processed: 0,
                  finished_at: DateTime.current,
                  seconds_taken: 0).exactly(:once)
          batch_transitioner.run
        end
      end
    end
  end
end
