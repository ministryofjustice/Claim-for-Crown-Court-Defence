module Subscribers
  class Slack < Base
    def process
      report_id = event.payload[:id]
      report_name = event.payload[:name]
      slack_notifier = SlackNotifier.new('laa-cccd-alerts', formatter: SlackNotifier::Formatter::Generic.new)
      slack_notifier.build_payload(
        icon: ':robot_face:',
        title: "#{report_name} failed on #{ENV['ENV']}",
        message: "Stats::StatsReport.id: #{report_id}",
        status: :fail
      )
      slack_notifier.send_message
    end
  end
end
