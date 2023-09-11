require 'rails_helper'

RSpec.describe SlackNotifier, :slack_bot do
  subject(:slack_notifier) { described_class.new('test-channel', formatter:) }

  let(:formatter) { SlackNotifier::Formatter.new }

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
        allow(formatter).to receive(:message_icon).and_return ':sign-roadworks:'
        slack_notifier.build_payload(key: 'value')
        send_message
      end

      it 'calls the slack api' do
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.once
      end

      it 'sets the channel' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(channel: 'test-channel', icon_emoji: ':sign-roadworks:'))
      end

      it 'sets the attachments' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(attachments: [{ title: 'Test title' }]))
      end
    end
  end
end
