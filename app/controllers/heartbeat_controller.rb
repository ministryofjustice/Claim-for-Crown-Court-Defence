class HeartbeatController < ApplicationController
  require 'sidekiq/api'

  skip_load_and_authorize_resource only: %i[ping healthcheck]

  respond_to :json

  def ping
    json = {
      'version_number'  => ENV['VERSION_NUMBER'] || 'Not Available',
      'build_date'      => ENV['BUILD_DATE'] || 'Not Available',
      'commit_id'       => ENV['COMMIT_ID'] || 'Not Available',
      'build_tag'       => ENV['BUILD_TAG'] || 'Not Available'
    }.to_json

    render json: json
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,
      num_claims: Claim::BaseClaim.count
    }

    status = :bad_gateway unless checks.values.all?
    render status: status, json: { checks: checks }
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

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
