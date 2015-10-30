class ZendeskFeedbackSender
  attr_accessor :feedback

  class << self
    def send!(feedback)
      ZendeskFeedbackSender.new(feedback).send!
    end
  end

  def initialize(feedback)
    @feedback = feedback
  end

  def send!
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      subject: "Feedback (#{Rails.host.env})",
      description: "#{feedback.rating} - #{feedback.comment} - #{feedback.email}",
      custom_fields: [
        { id: '26047167', value: feedback.referrer },
        { id: '23757677', value: 'advocate_defence_payments' },
        { id: '23791776', value: feedback.user_agent }
      ]
    )
  end
end
