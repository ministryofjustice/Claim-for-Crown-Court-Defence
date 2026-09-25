require 'sidekiq/api'

class HealthCheck
  def checks
    @checks ||= {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,
      num_claims: Claim::BaseClaim.count
    }
  end

  def healthy?
    checks.except(:sidekiq_queue).values.all?
  end

  private

  def redis_alive?
    Sidekiq.redis(&:info)
    true
  rescue StandardError
    false
  end

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    ps.size.positive?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.size.zero? && retries.size.zero? # rubocop:disable Style/ZeroLengthPredicate -- no `#empty?` on these classes
  rescue StandardError
    false
  end

  def database_alive?
    ActiveRecord::Base.connection.select_value('SELECT 1')
    true
  rescue StandardError
    false
  end
end
