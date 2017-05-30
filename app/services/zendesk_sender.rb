class ZendeskSender
  attr_accessor :ticket_payload

  class << self
    def send!(ticket_payload)
      ZendeskSender.new(ticket_payload).send!
    end
  end

  def initialize(ticket_payload)
    @ticket_payload = ticket_payload
  end

  def send!
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      subject: ticket_payload.subject,
      description: ticket_payload.description,
      custom_fields: [
        { id: '26047167', value: ticket_payload.referrer },
        { id: '23757677', value: 'advocate_defence_payments' },
        { id: '23791776', value: ticket_payload.user_agent },
        { id: '32342378', value: Rails.host.env }
      ]
    )
  end
end
