RSpec.describe ZendeskSender do
  subject(:sender) { ZendeskSender.new(ticket_payload) }
  let(:ticket_payload) { double('ticket_payload', subject: 'Bug report', description: 'event - outcome - email address', referrer: '/claims', user_agent: 'chrome') }

  before do
    allow(Rails).to receive(:host).and_return(double(env: 'test'))
    stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z})
  end

  describe '.send!' do
    it 'calls #send!' do
      expect(described_class).to receive(:new).with(ticket_payload).and_return(sender)
      expect(sender).to receive(:send!)
      described_class.send!(ticket_payload)
    end
  end

  describe '#send!' do
    let(:stubbed_request) do
      stub_request(:post, 'https://ministryofjustice.zendesk.com/api/v2/tickets').
        with(
          :body => '{"ticket":{"subject":"Bug report","description":"event - outcome - email address","custom_fields":[{"id":"26047167","value":"/claims"},{"id":"23757677","value":"advocate_defence_payments"},{"id":"23791776","value":"chrome"},{"id":"32342378","value":"test"}]}}',
          :headers => {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => /ZendeskAPI Ruby 1\.\d+\.\d+/
          }
        )
    end

    it 'calls ZendeskAPI::Ticket.create!' do
      expect(ZendeskAPI::Ticket).to receive(:create!)
      sender.send!
    end

    it 'makes the expected request, with common and custom fields' do
      sender.send!
      expect(stubbed_request).to have_been_requested
    end
  end
end
