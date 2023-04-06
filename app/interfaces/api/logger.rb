module API
  class Logger < Grape::Middleware::Base
    def before
      log_api_request(env['REQUEST_METHOD'], env['PATH_INFO'], env['rack.request.form_hash'])
    end

    def after
      log_api_response(JSON.parse(env['api.request.input'].to_s))
      @app_response # this must return @app_response or nil
    end

    private

    def log_api_request(method, path, data)
      log_api('api-request', method:, path:, data:)
    end

    def log_api_response(inputs)
      log_api('api-response', inputs:, status: response_status, response_body:)
    end

    def response_status
      return if @app_response.blank?

      @app_response.first.to_s
    end

    def response_body
      return if @app_response.blank?

      JSON.parse(@app_response[2].first)
    rescue JSON::ParserError
      Rails.logger.error "JSON::Parser error parsing: \n#{@app_response[2].first}"
    end

    def log_api(api_type, data)
      api_request = { log_type: api_type, timestamp: Time.zone.now }.merge!(data)
      Rails.logger.info api_request.to_json
    end
  end
end
