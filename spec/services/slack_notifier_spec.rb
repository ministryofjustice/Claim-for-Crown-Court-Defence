require 'rails_helper'

RSpec.describe SlackNotifier, slack_bot: true do
  subject(:slack_notifier) { described_class.new('test-slack-channel', formatter: formatter) }

  let(:formatter) { SlackNotifier::Formatter.new }

  describe '#send_message!' do
    subject(:send_message) { slack_notifier.send_message! }

    context 'without a payload' do
      # TODO: Is this the correct behaviour? Would it be better to send the
      #       error to Slack?
      it { expect { send_message }.to raise_error(RuntimeError, 'Unable to send without payload') }
    end

    context 'with a generic payload' do
      let(:expected_payload) do
        WebMock.hash_including(
          {
            icon_emoji: ':tada:',
            channel: 'test-slack-channel',
            username: 'monitor_bot',
            attachments: [WebMock.hash_including(
              {
                title: 'Message title',
                text: 'The body of the message',
                fallback: 'The body of the message'
              }
            )]
          }
        )
      end

      before do
        slack_notifier.build_generic_payload(':tada:', 'Message title', 'The body of the message', true)
        send_message
      end

      it { expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1) }

      it do
        expect(WebMock).to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: expected_payload)
      end
    end

    context 'with an injection payload' do
      let(:formatter) { SlackNotifier::Formatter::Injection.new }
      let(:valid_json_on_success) do
        {
          from: 'external application',
          errors: [],
          uuid: '12345678-90ab-cdef-1234-567890abcdef',
          messages: [{ message: 'Claim injected successfully.' }]
        }
      end
      let(:expected_payload) do
        WebMock.hash_including(
          {
            icon_emoji: ':bad_icon:',
            channel: 'test-slack-channel',
            username: 'monitor_bot',
            attachments: [WebMock.hash_including(
              {
                title: 'Injection into external application failed',
                text: '12345678-90ab-cdef-1234-567890abcdef',
                fallback: 'Failed to inject because no claim found {12345678-90ab-cdef-1234-567890abcdef}'
              }
            )]
          }
        )
      end

      before do
        slack_notifier.build_injection_payload(valid_json_on_success)
        send_message
      end

      it 'calls the slack api' do
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1)
      end

      it do
        expect(WebMock).to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: expected_payload)
      end
    end
  end
end
