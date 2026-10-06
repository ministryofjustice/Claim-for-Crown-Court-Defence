require 'rails_helper'

RSpec.describe SlackNotifier, :slack_bot do
  subject(:slack_notifier) { described_class.new('laa-cccd-alerts', formatter:) }

  let(:formatter) { described_class::Formatter.new }

  describe '#send_message' do
    subject(:send_message) { slack_notifier.send_message }

    context 'when a payload has not been generated' do
      it 'raises an error' do
        expect { send_message }.to raise_error(RuntimeError, 'Unable to send without payload')
      end
    end

    context 'when a payload has been generated' do
      before do
        allow(formatter).to receive(:attachment).with(hash_including(key: 'value')).and_return({ title: 'Test title' })
        slack_notifier.build_payload(key: 'value')
        send_message
      end

      it 'calls the slack api' do
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/alerts')).to have_been_made.once
      end

      it 'sets the attachments' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/alerts')
          .with(body: hash_including(attachments: [{ title: 'Test title' }]))
      end
    end
  end

  describe 'webhook selection' do
    {
      'laa-cccd-alerts' => 'alerts',
      'cccd_development' => 'development',
      'cccd_ccr_injection' => 'ccr-injection',
      'cccd_cclf_injection' => 'cclf-injection'
    }.each do |channel, destination|
      it "uses the #{destination} webhook for #{channel}" do
        send_notification(channel)
        expect(a_request(:post, "https://hooks.slack.com/services/fake/#{destination}")).to have_been_made.once
      end
    end

    it 'rejects channels without a configured webhook' do
      expect { described_class.new('unknown-channel', formatter:) }
        .to raise_error(ArgumentError, 'No Slack webhook configured for channel: unknown-channel')
    end

    def send_notification(channel)
      notifier = described_class.new(channel, formatter:)
      allow(formatter).to receive(:attachment).and_return(title: 'Test')
      notifier.build_payload
      notifier.send_message
    end
  end
end
