class ZendeskSender
  FEEDBACK_TYPES = {
    feedback: %i[task rating comment reason other_reason],
    bug_report: %i[case_number event outcome email]
  }.freeze

  attr_accessor :ticket_payload

  def self.call(...)
    new(...).call
  end

  def initialize(ticket_payload)
    @ticket_payload = ticket_payload
  end

  def call
    create_ticket
    { success: true, response_message: "#{feedback_type.titleize} submitted" }
  rescue ZendeskAPI::Error::ClientError => e
    catch_error(e)
  end

  private

  def feedback_type
    @ticket_payload.type.humanize
  end

  def feedback_type_attributes
    FEEDBACK_TYPES[@ticket_payload.type.to_sym]
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{@ticket_payload.send(t)}" }.join("\n")
  end

  def create_ticket
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      **base_params,
      **email_params,
      **custom_params
    )
  end

  def catch_error(error)
    LogStuff.error(class: self.class.name, action: 'save', error_class: error.class.name, error: error.to_s) do
      "#{feedback_type.titleize} submission failed!"
    end
    { success: false, response_message: "Unable to submit #{feedback_type.downcase}" }
  end

  def reporter_email
    return if @ticket_payload.email.blank? || @ticket_payload.email == 'anonymous'

    @ticket_payload.email
  end

  def subject
    "#{@ticket_payload.type.humanize} (#{Rails.host.env})"
  end

  def base_params
    {
      subject:,
      description:
    }
  end

  def email_params
    return {} if reporter_email.blank?

    { email_ccs: [{ user_email: reporter_email }] }
  end

  def custom_params
    {
      custom_fields: [
        { id: '26047167', value: ticket_payload.referrer },
        { id: '23757677', value: 'advocate_defence_payments' },
        { id: '23791776', value: ticket_payload.user_agent },
        { id: '32342378', value: Rails.host.env }
      ]
    }
  end
end
