class ZendeskBugReportSender
  attr_accessor :bug_report

  class << self
    def send!(bug_report)
      ZendeskBugReportSender.new(bug_report).send!
    end
  end

  def initialize(bug_report)
    @bug_report = bug_report
  end

  def send!
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      subject: "BUG (#{Rails.host.env})",
      description: "#{bug_report.event} - #{bug_report.outcome} - #{bug_report.email}",
      custom_fields: [
        { id: '26047167', value: bug_report.referrer },
        { id: '23757677', value: 'advocate_defence_payments' },
        { id: '23791776', value: bug_report.user_agent }
      ]
    )
  end
end
