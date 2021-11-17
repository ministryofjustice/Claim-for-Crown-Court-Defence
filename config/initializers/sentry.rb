# frozen_string_literal: true

if Rails.env.eql?('production') && ENV['SENTRY_DSN'].present?
   Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger]

    # Send 5% of transactions for performance monitoring
    config.traces_sample_rate = 0.05

    config.capture_exception_frame_locals = true
  end
end
