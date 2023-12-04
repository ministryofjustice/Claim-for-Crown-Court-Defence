# Sidekiq uses Redis to store all of its job and operational data.
# By default, Sidekiq tries to connect to Redis at localhost:6379
#
# You can also set the Redis url using environment variables.
# The generic REDIS_URL may be set to specify the Redis server.
#
# Otherwise it can be configured here using both the blocks
# Sidekiq.configure_server and Sidekiq.configure_client
#
# https://github.com/mperham/sidekiq/wiki/Using-Redis

Sidekiq.default_job_options = { retry: 5 }

# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
if ENV['INLINE_SIDEKIQ'].eql?('true')
  raise 'Sidekiq must be run using redis in production' unless Rails.env.development?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

if Rails.env.test?
  Sidekiq.logger.level = Logger::WARN
end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    if ENV['DISABLE_SCHEDULED_TASK'].eql?('true') && (Rails.env.development? || Rails.env.test?)
      Sidekiq.schedule = {}
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end
end