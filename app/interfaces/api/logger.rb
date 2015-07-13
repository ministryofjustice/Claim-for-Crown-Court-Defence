class API::Logger < Grape::Middleware::Base

  def before
    log_api_request(env['REQUEST_METHOD'], env['PATH_INFO'], env['rack.request.form_hash'])
  end

  def after
    log_api_response(@app_response.status, JSON.parse(@app_response.body.first))
    @app_response # this must return @app_response or nil
  end

  private

  def log_api_request(method, path, data)
    log_api('api-request', { method: method, path: path, data: data })
  end

  def log_api_response(status, response_body)
    log_api('api-response', { status: status, response_body: response_body })
  end

  def log_api(api_type, data)
    api_request = { log_type: api_type, timestamp: Time.now }.merge!(data)
    Rails.logger.info api_request.to_json
  end

end
