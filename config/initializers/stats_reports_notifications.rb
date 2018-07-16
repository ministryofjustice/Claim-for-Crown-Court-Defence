ActiveSupport::Notifications.subscribe 'call_failed.stats_report' do |*args|
  Subscribers::Slack.new(*args)
end
