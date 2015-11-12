require 'raven'

unless %w( test ).include?(Rails.env)
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.environments = %w( production )
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
