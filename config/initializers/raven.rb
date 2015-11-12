require 'raven'

unless %w( test ).include?(Rails.env)
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
  end
end
