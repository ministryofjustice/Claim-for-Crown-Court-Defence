require 'rails_helper'

RSpec.describe Schedule::HealthcheckReport do
  subject(:report) { described_class.new }

  describe '#perform' do
    subject(:perform) { report.perform }

    let(:health_check) { instance_double(HealthCheck, checks:) }
    let(:checks) do
      { database: true, redis: true, sidekiq: true, sidekiq_queue: true, num_claims: 42 }
    end
    let(:notifier) { instance_double(SlackNotifier) }
    let(:slack_response) { instance_double(Faraday::Response, success?: true, status: 200) }
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
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('ENV', nil).and_return('dev')
      allow(Settings).to receive(:healthcheck_report_enabled).and_return(true)
      allow(HealthCheck).to receive(:new).and_return(health_check)
      allow(SlackNotifier).to receive(:new).and_return(notifier)
      allow(notifier).to receive(:build_payload)
      allow(notifier).to receive(:send_message).and_return(slack_response)
    end

    context 'when Slack accepts the webhook' do
      before { perform }

      it 'creates a new SlackNotifier for the alerts channel' do
        expect(SlackNotifier)
          .to have_received(:new)
          .with('laa-cccd-alerts', formatter: an_instance_of(SlackNotifier::Formatter::Generic))
      end

      it 'builds the payload with the environment and a summary of the checks' do
        expect(notifier).to have_received(:build_payload).with(
          icon: ':penguin:', title: 'Daily healthcheck on dev', message: expected_message, status: :pass
        )
      end

      it 'sends the message' do
        expect(notifier).to have_received(:send_message)
      end

      context 'when a dependency check has failed' do
        let(:checks) { super().merge(redis: false) }

        it 'sets the status to fail' do
          expect(notifier).to have_received(:build_payload).with(hash_including(status: :fail))
        end
      end

      context 'when there are dead or retrying Sidekiq jobs' do
        let(:checks) { super().merge(sidekiq_queue: false) }

        it 'sets the status to fail' do
          expect(notifier).to have_received(:build_payload).with(hash_including(status: :fail))
        end
      end

      context 'when the claim count is unavailable' do
        let(:checks) { super().merge(database: false, num_claims: nil) }

        it 'reports the claim count as unavailable' do
          expect(notifier).to have_received(:build_payload)
            .with(hash_including(message: a_string_including('Number of claims: :x: unavailable')))
        end
      end
    end

    context 'when Slack rejects the webhook' do
      let(:slack_response) { instance_double(Faraday::Response, success?: false, status: 500) }

      it 'raises so that Sidekiq retries delivery' do
        expect { perform }.to raise_error(described_class::DeliveryError, /HTTP 500/)
      end
    end

    context 'when the healthcheck report is disabled for this environment' do
      before do
        allow(Settings).to receive(:healthcheck_report_enabled).and_return(false)
        perform
      end

      it 'does not send a message' do
        expect(notifier).not_to have_received(:send_message)
      end
    end
  end
end
