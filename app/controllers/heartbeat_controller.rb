class HeartbeatController < ApplicationController
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
    health_check = HealthCheck.new
    status = :bad_gateway unless health_check.healthy?
    render status:, json: { checks: health_check.checks }
  end
end
