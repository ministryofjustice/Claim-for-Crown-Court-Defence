RSpec.describe ZendeskSender do
  describe '#call' do
    subject(:zen_call) { described_class.call(params) }

    let(:params) do
      instance_double(
        Feedback,
        type: 'bug_report',
        referrer: '/claims',
        user_agent: 'chrome',
        case_number: '1234',
        event: 'test',
        outcome: 'an outcome',
        email: nil
      )
    end

    let(:payload) do
      {
        subject: 'Bug report (test_environment)',
        description: "case_number: 1234\nevent: test\noutcome: an outcome\nemail: ",
        custom_fields: [
          { id: '26047167', value: '/claims' },
          { id: '23757677', value: 'advocate_defence_payments' },
          { id: '23791776', value: 'chrome' },
          { id: '32342378', value: 'test_environment' }
        ]
      }
    end

    before do
      stub_const('ENV', ENV.to_hash.merge('ENV' => 'test_environment'))
      allow(ZendeskAPI::Ticket).to receive(:create!)
    end

    it 'calls ZendeskAPI::Ticket.create!' do
      zen_call
      expect(ZendeskAPI::Ticket)
        .to have_received(:create!)
        .with(ZENDESK_CLIENT, hash_including(payload))
    end

    context 'with a valid ticket and reporter email' do
      let(:params) do
        instance_double(
          Feedback,
          type: 'bug_report',
          referrer: '/claims',
          user_agent: 'chrome',
          case_number: '1234',
          event: 'test',
          outcome: 'an outcome',
          email: 'example@example.com'
        )
      end

      it 'includes the reporter email' do
        zen_call
        expect(ZendeskAPI::Ticket)
          .to have_received(:create!)
          .with(ZENDESK_CLIENT, hash_including(email_ccs: [{ user_email: 'example@example.com' }]))
      end

      it 'returns a success value and a response message' do
        expect(zen_call).to eq({ success: true, response_message: 'Bug Report submitted' })
      end
    end

    context 'with a blank email' do
      let(:params) do
        instance_double(
          Feedback,
          type: 'bug_report',
          referrer: '/claims',
          user_agent: 'chrome',
          case_number: '1234',
          event: 'test',
          outcome: 'an outcome',
          email: ''
        )
      end

      it 'does not include the reporter email' do
        zen_call
        expect(ZendeskAPI::Ticket)
          .to have_received(:create!)
          .with(ZENDESK_CLIENT, hash_not_including(email_ccs: anything))
      end
    end

    context 'with an anonymous email' do
      let(:params) do
        instance_double(
          Feedback,
          type: 'bug_report',
          referrer: '/claims',
          user_agent: 'chrome',
          case_number: '1234',
          event: 'test',
          outcome: 'an outcome',
          email: 'anonymous'
        )
      end

      it 'does not include the reporter email' do
        zen_call
        expect(ZendeskAPI::Ticket)
          .to have_received(:create!)
          .with(ZENDESK_CLIENT, hash_not_including(email_ccs: anything))
      end
    end

    context 'when an error occurs' do
      before do
        allow(ZendeskAPI::Ticket)
          .to receive(:create!)
          .and_raise ZendeskAPI::Error::ClientError, 'oops, something went wrong'
        allow(LogStuff).to receive(:error)
      end

      it 'returns a failure value and message' do
        expect(zen_call).to eq({ success: false, response_message: 'Unable to submit bug report' })
      end

      it 'logs error details' do
        zen_call
        expect(LogStuff)
          .to have_received(:error)
          .with(class: described_class.to_s, action: 'save',
                error_class: 'ZendeskAPI::Error::ClientError', error: 'oops, something went wrong')
      end
    end
  end
end
