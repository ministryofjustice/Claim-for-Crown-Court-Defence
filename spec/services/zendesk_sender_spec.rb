RSpec.describe ZendeskSender do
  shared_examples 'Zendesk send' do
    let(:ticket_payload) do
      instance_double(
        Feedback,
        subject: 'Bug report',
        description: 'event - outcome - email address',
        referrer: '/claims',
        user_agent: 'chrome'
      )
    end

    let(:zendesk_payload) do
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
      zen_send
      expect(ZendeskAPI::Ticket).to have_received(:create!).with(ZENDESK_CLIENT, **zendesk_payload)
    end
  end

  describe '.send!' do
    include_examples 'Zendesk send' do
      subject(:zen_send) { described_class.send!(ticket_payload) }
    end
  end

  describe '#send!' do
    include_examples 'Zendesk send' do
      subject(:zen_send) { described_class.new(ticket_payload).send! }
    end
  end
end
