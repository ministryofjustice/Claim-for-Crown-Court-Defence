RSpec.describe ZendeskSender do
  describe '#call' do
    subject(:zen_call) { described_class.call(ticket_payload) }

    let(:bug_report_ticket_payload) do
      instance_double(
        Feedback,
        subject: 'Bug report',
        description: 'event - outcome - email address',
        referrer: '/claims',
        user_agent: 'chrome',
        reporter_email: nil
      )
    end

    let(:bug_report_zendesk_payload) do
      {
        subject: 'Bug report',
        description: 'event - outcome - email address',
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
      expect(ZendeskAPI::Ticket).to have_received(:create!).with(ZENDESK_CLIENT, hash_including(bug_report_zendesk_payload))
    end

    context 'with a reporter email' do
      let(:ticket_payload) do
        instance_double(
          Feedback,
          subject: 'Bug report',
          description: 'event - outcome - email address',
          referrer: '/claims',
          user_agent: 'chrome',
          reporter_email: 'example@example.com'
        )
      end

      it 'includes the reporter email' do
        zen_call
        expect(ZendeskAPI::Ticket)
          .to have_received(:create!)
                .with(ZENDESK_CLIENT, hash_including(email_ccs: [{ user_email: 'example@example.com' }]))
      end

      it 'returns a success value and a response message' do
        expect(zen_call).to eq({ success: kind_of(Boolean), response_message: kind_of(String) })
      end
    end

    #TODO: write a test here to test error reporting, removed from feedback spec
  end
end
