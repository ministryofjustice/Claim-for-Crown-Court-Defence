module Subscribers
  class Slack < Base
    def process
      report_id = event.payload[:id]
      report_name = event.payload[:name]
      slack = SlackNotifier.new('cccd_development')
      slack.build_generic_payload(':robot_face:',
                                  "#{report_name} failed on #{ENV['ENV']}",
                                  "Stats::StatsReport.id: #{report_id}",
                                  false)
      slack.send_message!
    end
  end
end
