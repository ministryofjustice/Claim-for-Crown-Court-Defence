class HeartbeatController  < ApplicationController
  skip_load_and_authorize_resource only: [:ping, :healthcheck]

  respond_to :json

  def ping
    json = {
      'version_number'  => ENV['VERSION_NUMBER'] || "Not Available",
      'build_date'      => ENV['BUILD_DATE'] || 'Not Available',
      'commit_id'       => ENV['COMMIT_ID'] || 'Not Available',
      'build_tag'       => ENV['BUILD_TAG'] || "Not Available"
    }.to_json

    render json: json
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?
    }

    status = :bad_gateway unless checks.values.all?
    render status: status, json: {
      checks: checks
    }
  end

  private

  def redis_alive?
    begin
      Sidekiq.redis { |conn| conn.info }
      true
    rescue => e
      false
    end
  end

  def database_alive?
    begin
      ActiveRecord::Base.connection.active?
    rescue PG::ConnectionBad
      false
    end
  end
end
