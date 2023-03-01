class HeartbeatController < ApplicationController
  require 'sidekiq/api'

  skip_load_and_authorize_resource only: %i[ping healthcheck]

  respond_to :json

  def ping
    json = {
      'version_number' => ENV.fetch('VERSION_NUMBER', 'Not Available'),
      'build_date' => ENV.fetch('BUILD_DATE', 'Not Available'),
      'commit_id' => ENV.fetch('COMMIT_ID', 'Not Available'),
      'build_tag' => ENV.fetch('BUILD_TAG', 'Not Available'),
      'app_branch' => ENV.fetch('APP_BRANCH', 'Not Available')
    }.to_json

    render json:
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,
      num_claims: Claim::BaseClaim.count
    }

    status = :bad_gateway unless checks.except(:sidekiq_queue).values.all?
    render status:, json: { checks: }
  end

  private

  def redis_alive?
    Sidekiq.redis(&:info)
    true
  rescue StandardError
    false
  end

  # Sidekik does not support `#empty?`
  # rubocop:disable Style/ZeroLengthPredicate
  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.size.zero?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.size.zero? && retries.size.zero?
  rescue StandardError
    false
  end
  # rubocop:enable Style/ZeroLengthPredicate

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
