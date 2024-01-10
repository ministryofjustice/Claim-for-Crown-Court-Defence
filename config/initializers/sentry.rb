# frozen_string_literal: true

if Rails.env.eql?('production') && ENV['SENTRY_DSN'].present?
   Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :redis_logger]

    # Send 5% of transactions for performance monitoring
    config.traces_sample_rate = 0.05
    config.enabled_patches += [:sidekiq_scheduler]
   end

   # Create a config from a crontab schedule (every 10 minutes)
   monitor_config = Sentry::Cron::MonitorConfig.from_interval(
     10,
     :minute,
     checkin_margin: 5, # Optional check-in margin in minutes
     max_runtime: 15, # Optional max runtime in minutes
     timezone: 'Europe/London', # Optional timezone
     )

   # 🟡 Notify Sentry your job is running:
   check_in_id = Sentry.capture_check_in(
     '<monitor-slug>',
     :in_progress,
     monitor_config: monitor_config
   )

   # Execute your scheduled task here...

   # 🟢 Notify Sentry your job has completed successfully:
   Sentry.capture_check_in(
     '<monitor-slug>',
     :ok,
     check_in_id: check_in_id,
     monitor_config: monitor_config
   )

   Sentry.capture_check_in(
     '<monitor-slug>',
     :error,
     check_in_id: check_in_id,
     monitor_config: monitor_config
   )
end
