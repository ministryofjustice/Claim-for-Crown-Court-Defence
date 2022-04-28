module Subscribers
  class Slack < Base
    def process
      slack_notifier = SlackNotifier.new('laa-cccd-alerts', formatter: SlackNotifier::Formatter::Generic.new)
      slack_notifier.build_payload(
        icon: ':robot_face:',
        title: "#{event.payload[:name]} failed on #{ENV.fetch('ENV', nil)}",
        message: "Error: #{event.payload[:error].message}\nStats::StatsReport.id: #{event.payload[:id]}",
        status: :fail
      )
      slack_notifier.send_message
    end
  end
end
