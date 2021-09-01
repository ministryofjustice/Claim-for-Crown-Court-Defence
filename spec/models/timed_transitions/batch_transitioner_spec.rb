require 'rails_helper'

RSpec.shared_examples 'run all transitioners' do
  let(:claim_ids) { [22, 878] }
  let(:claim22) { instance_double 'Claim 22', state: 'authorised', last_state_transition_time: 2.days.ago }
  let(:claim878) { instance_double 'Claim 878', state: 'authorised', last_state_transition_time: 2.days.ago }
  let(:transitioner22) { instance_double('Transitioner 22', success?: true) }
  let(:transitioner878) { instance_double('Transitioner 878', success?: true) }

  before do
    allow(TimedTransitions::Transitioner).to receive(:candidate_claims_ids).and_return(claim_ids)
    allow(Claim::BaseClaim).to receive(:find).with(22).and_return(claim22)
    allow(Claim::BaseClaim).to receive(:find).with(878).and_return(claim878)
    allow(TimedTransitions::Transitioner).to receive(:new).with(claim22, dummy).and_return transitioner22
    allow(TimedTransitions::Transitioner).to receive(:new).with(claim878, dummy).and_return transitioner878
    allow(transitioner22).to receive(:run)
    allow(transitioner878).to receive(:run)
    allow(LogStuff).to receive(:info)
  end

  it 'creates a transitioner for the first claim' do
    batch_transitioner_run
    expect(TimedTransitions::Transitioner).to have_received(:new).with(claim22, dummy)
  end

  it 'runs the transitioner for the first claim' do
    batch_transitioner_run
    expect(transitioner22).to have_received(:run)
  end

  it 'creates a transitioner for the second claim' do
    batch_transitioner_run
    expect(TimedTransitions::Transitioner).to have_received(:new).with(claim878, dummy)
  end

  it 'runs the transitioner for the second claim' do
    batch_transitioner_run
    expect(transitioner878).to have_received(:run)
  end

  it 'increments the transaction counter twice' do
    expect { batch_transitioner_run }.to change(batch_transitioner, :transitions_counter).by 2
  end

  it 'logs at the start of the run' do
    batch_transitioner_run
    expect(LogStuff).to have_received(:info)
      .with('TimedTransitions::BatchTransitioner', hash_including(claims_processed: nil, finished_at: nil))
      .exactly(:once)
  end

  it 'logs at the end of the run' do
    batch_transitioner_run
    expect(LogStuff).to have_received(:info)
      .with('TimedTransitions::BatchTransitioner', hash_including(claims_processed: 2,
                                                                  finished_at: instance_of(DateTime)))
      .exactly(:once)
  end

  context 'with a limit' do
    let(:options) { { dummy: dummy, limit: 1 } }

    it 'creates a transitioner for the first claim' do
      batch_transitioner_run
      expect(TimedTransitions::Transitioner).to have_received(:new).with(claim22, dummy)
    end

    it 'runs the transitioner for the first claim' do
      batch_transitioner_run
      expect(transitioner22).to have_received(:run)
    end

    it 'does not run the transitioner for the second claim' do
      batch_transitioner_run
      expect(transitioner878).not_to have_received(:run)
    end

    it 'increments the transaction counter' do
      expect { batch_transitioner_run }.to change(batch_transitioner, :transitions_counter).by 1
    end

    it 'logs at the end of the run' do
      batch_transitioner_run
      expect(LogStuff).to have_received(:info)
        .with('TimedTransitions::BatchTransitioner', hash_including(claims_processed: 1,
                                                                    finished_at: instance_of(DateTime)))
        .exactly(:once)
    end
  end
end

RSpec.describe TimedTransitions::BatchTransitioner, slack_bot: true do
  subject(:batch_transitioner) { described_class.new(**options) }

  let(:options) { { dummy: dummy } }

  describe '#run' do
    subject(:batch_transitioner_run) { batch_transitioner.run }

    context 'with a non dummy run' do
      let(:dummy) { false }

      include_examples 'run all transitioners'

      context 'with a sample of test transitions' do
        let(:claim) { instance_double 'Claim' }
        let(:transitioner) { instance_double('Transitioner') }
        let(:slack_notifier) { instance_double('SlackNotifier') }

        before do
          allow(TimedTransitions::Transitioner).to receive(:candidate_claims_ids).and_return([1, 2, 3, 4, 5])
          allow(Claim::BaseClaim).to receive(:find).and_return(claim)
          allow(TimedTransitions::Transitioner).to receive(:new).with(claim, dummy).and_return transitioner
          allow(transitioner).to receive(:run)
          allow(transitioner).to receive(:success?).and_return(
            true,
            true,
            false,
            false,
            true
          )
          allow(SlackNotifier).to receive(:new).and_return(slack_notifier)
          allow(slack_notifier).to receive(:build_payload)
          allow(slack_notifier).to receive(:send_message)
        end

        it 'creates Slack attachment with tally of succeeded and failed transitions' do
          batch_transitioner_run
          expect(slack_notifier).to have_received(:build_payload).with(processed: 3, failed: 2)
        end
      end
    end

    context 'with a dummy run' do
      let(:dummy) { true }

      include_examples 'run all transitioners'
    end
  end
end
