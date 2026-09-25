require 'rails_helper'

RSpec.describe Schedule::HealthcheckReport do
  subject(:report) { described_class.new }

  describe '#perform' do
    subject(:perform) { report.perform }

    let(:health_check) { instance_double(HealthCheck, checks:, healthy?: healthy) }
    let(:checks) do
      { database: true, redis: true, sidekiq: true, sidekiq_queue: true, num_claims: 42 }
    end
    let(:healthy) { true }
    let(:notifier) { instance_double(SlackNotifier) }
    let(:expected_message) do
      [
        'Database connection: :white_check_mark:',
        'Redis connection: :white_check_mark:',
        'Sidekiq process running: :white_check_mark:',
        'No dead or retrying Sidekiq jobs: :white_check_mark:',
        'Number of claims: 42'
      ].join("\n")
    end

    before do
      allow(Settings).to receive(:healthcheck_report_enabled).and_return(true)
      allow(HealthCheck).to receive(:new).and_return(health_check)
      allow(SlackNotifier).to receive(:new).and_return(notifier)
      allow(notifier).to receive(:build_payload)
      allow(notifier).to receive(:send_message)

      perform
    end

    it 'creates a new SlackNotifier for the alerts channel' do
      expect(SlackNotifier)
        .to have_received(:new)
        .with('laa-cccd-alerts', formatter: an_instance_of(SlackNotifier::Formatter::Generic))
    end

    it 'builds the payload with a summary of the checks' do
      expect(notifier).to have_received(:build_payload).with(
        icon: ':penguin:', title: 'Daily healthcheck', message: expected_message, status: :pass
      )
    end

    it 'sends the message' do
      expect(notifier).to have_received(:send_message)
    end

    context 'when a check has failed' do
      let(:healthy) { false }

      it 'sets the status to fail' do
        expect(notifier).to have_received(:build_payload).with(hash_including(status: :fail))
      end
    end

    context 'when the healthcheck report is disabled for this environment' do
      before do
        allow(Settings).to receive(:healthcheck_report_enabled).and_return(false)
      end

      it 'does not build or send a message' do
        perform

        aggregate_failures do
          expect(notifier).to have_received(:build_payload).once # from the enabled outer before, not this one
          expect(notifier).to have_received(:send_message).once
        end
      end
    end
  end
end
