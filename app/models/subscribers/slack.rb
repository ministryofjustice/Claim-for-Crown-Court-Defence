module Subscribers
  class Slack < Base
    def process
      report_id = event.payload[:id]
      report_name = event.payload[:name]
      slack = SlackNotifier.new('cccd_development', formatter: SlackNotifier::Formatter.new)
      slack.build_payload(
        icon: ':robot_face:',
        title: "#{report_name} failed on #{ENV['ENV']}",
        message: "Stats::StatsReport.id: #{report_id}",
        status: :fail
      )
      slack.send_message!
    end
  end
end
