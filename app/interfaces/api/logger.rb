module API
  class Logger < Grape::Middleware::Base
    def before
      log_api(:info, 'api-request', { method: env['REQUEST_METHOD'], claim_id: request_data['claim_id'],
                                      case_number: request_data['case_number'], **request_data_log })
    end

    def after
      return if response_status.nil?

      if response_status.between?(200, 399)
        log_api(:info, 'api-response',
                { status: response_status, claim_id: response_param('claim_id'),
                  case_number: response_param('case_number'), id: response_param('id'), **request_data_log })
      else
        log_error('api-error', { status: response_status, **request_data_log }, response_param('error'))
      end
      @app_response # this must return @app_response or nil
    end

    private

    def request_data_log
      {
        request_id:,
        path:,
        creator_email:,
        user_email:,
        input_parameters: request_data.keys
      }
    end

    def request_id
      env['action_dispatch.request_id']
    end

    def path
      env['PATH_INFO']
    end

    def request_data
      return env['api.rquest.input'] if env['api.request.input'].present?
      return env['rack.request.form_hash'] if env['rack.request.form_hash'].present?
      return env['rack.request.query_hash'] if env['rack.request.query_hash'].present?

      {}
    end

    def creator_email
      return if request_data['creator_email'].blank?

      sanitised_email(request_data['creator_email'])
    end

    def user_email
      return if request_data['user_email'].blank?

      sanitised_email(request_data['user_email'])
    end

    def sanitised_email(email)
      name, domain, extension = email.split(/[@.]/, 3)

      "#{redact(name)}@#{redact(domain)}.#{extension}"
    rescue NoMethodError
      'Invalid email, cannot be redacted'
    end

    def redact(input)
      input[0] +
        ('*' * (input.length - 2)) +
        input[-1]
    end

    def response_status
      return if @app_response.blank?

      @app_response.first
    end

    def response_param(param)
      response_body[0][param]
    rescue NoMethodError
      nil
    end

    def response_body
      @response_body = [{}] if @app_response.blank?

      @response_body ||= JSON.parse(@app_response[2].first)
    rescue JSON::ParserError => e
      log_error('api-response-body',
                { request_id: env['action_dispatch.request_id'] },
                "Error parsing API response body: \n#{e.class} - #{e.message}")
      @response_body = [{}]
    end

    def log_api(level, type, data)
      LogStuff.send(
        level.to_sym,
        type:,
        data:
      ) do
        "#{type} logged"
      end
    end

    def log_error(type, data, error)
      LogStuff.send(
        :error,
        type:,
        data:,
        error:
      ) do
        'API error logged'
      end
    end
  end
end
