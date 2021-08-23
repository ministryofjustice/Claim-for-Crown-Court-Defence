require 'rails_helper'

RSpec.describe SlackNotifier, slack_bot: true do
  subject(:slack_notifier) { described_class.new('test-channel') }

  describe '#send_message!' do
    subject(:send_message) { slack_notifier.send_message! }

    context 'when a payload has not been generated' do
      it 'raises an error' do
        expect { send_message }.to raise_error(RuntimeError, 'Unable to send without payload')
      end
    end

    context 'when a generic payload has been generated' do
      let(:valid_parameters) { [':robot-face:', 'Test title', 'Test message', true] }
      let(:expected_attachment) do
        {
          fallback: 'Test message',
          color: '#36a64f',
          title: 'Test title',
          text: 'Test message'
        }
      end

      before do
        slack_notifier.build_generic_payload(*valid_parameters)
        send_message
      end

      it 'calls the slack api' do
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1)
      end

      it 'sets the channel' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(channel: 'test-channel'))
      end

      it 'sets the attachments' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(attachments: [expected_attachment]))
      end
    end

    context 'when an injection payload has been generated' do
      let(:claim) { create :claim }
      let(:json_response) do
        {
          from: 'external application',
          errors: [],
          uuid: claim.uuid,
          messages: [{ message: 'Claim injected successfully.' }]
        }
      end
      # TODO: This isn't used. Is there a missing test or is it redundant?
      let(:valid_json_on_failure) do
        {
          from: 'external application',
          errors: [{ error: "No defendant found for Rep Order Number: '123456432'." }],
          uuid: claim.uuid,
          messages: []
        }
      end
      let(:expected_attachment) do
        {
          fallback: "Claim #{claim.case_number} successfully injected {#{claim.uuid}}",
          color: '#36a64f',
          title: 'Injection into external application succeeded',
          text: claim.uuid,
          fields: [
            { title: 'Claim number', value: claim.case_number, short: true },
            { title: 'environment', value: 'test', short: true }
          ]
        }
      end

      before do
        slack_notifier.build_injection_payload(json_response)
        send_message
      end

      it 'calls the slack api' do
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1)
      end

      it 'sets the channel' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(channel: 'test-channel'))
      end

      it 'sets the attachments' do
        expect(WebMock)
          .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
          .with(body: hash_including(attachments: [expected_attachment]))
      end

      context 'with errors' do
        let(:json_response) do
          {
            from: 'external application',
            errors: [{ error: "No defendant found for Rep Order Number: '123456432'." }],
            uuid: claim.uuid,
            messages: []
          }
        end
        let(:expected_attachment) do
          {
            fallback: "Claim #{claim.case_number} could not be injected {#{claim.uuid}}",
            color: '#c41f1f',
            title: 'Injection into external application failed',
            text: claim.uuid,
            fields: [
              { title: 'Claim number', value: claim.case_number, short: true },
              { title: 'environment', value: 'test', short: true },
              { title: 'Errors', value: '' }
            ]
          }
        end

        it 'sets the attachments' do
          expect(WebMock)
            .to have_requested(:post, 'https://hooks.slack.com/services/fake/endpoint')
            .with(body: hash_including(attachments: [expected_attachment]))
        end
      end
    end
  end
end
