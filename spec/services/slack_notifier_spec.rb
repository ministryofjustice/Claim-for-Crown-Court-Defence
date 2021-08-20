require 'rails_helper'

RSpec.describe SlackNotifier, slack_bot: true do
  subject(:slack_notifier) { described_class.new('test-slack-channel', formatter: formatter) }

  let(:formatter) { SlackNotifier::Formatter.new }

  describe '#send_message!' do
    subject(:send_message) { slack_notifier.send_message! }

    context 'when the formatter is not ready to send' do
      before { allow(formatter).to receive(:ready_to_send).and_return false }

      # TODO: Is this the correct behaviour? Would it be better to send the
      #       error to Slack?
      it { expect { send_message }.to raise_error(RuntimeError, 'Unable to send without payload') }
    end

    context 'when the formatter is ready to send' do
      let(:payload) { { icon_emoji: ':eyes:', attachments: [{ title: 'Hello' }] } }

      before do
        allow(formatter).to receive(:ready_to_send).and_return true
        allow(formatter).to receive(:payload).and_return payload
        send_message
      end

      it { expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1) }

      it do
        expect(WebMock).to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: payload)
      end
    end
  end

  describe '#build_payload' do
    subject(:build_payload) { slack_notifier.build_payload(**args) }

    let(:args) { { key1: 1, key2: 2 } }

    before do
      allow(formatter).to receive(:build)
      build_payload
    end

    it { expect(formatter).to have_received(:build).with(**args) }
  end
end
