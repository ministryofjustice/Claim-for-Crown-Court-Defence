require 'raven'

unless %w( test ).include?(Rails.env)
  Raven.configure do |config|
    config.environments = %w( production )
    config.dsn = ENV['SENTRY_DSN']
  end
end
