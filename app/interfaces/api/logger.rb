module API
  class Logger < Grape::Middleware::Base
    def before
      log_api(:info,
              'api-request',
              { request_id: env['action_dispatch.request_id'],
                method: env['REQUEST_METHOD'],
                path: env['PATH_INFO'],
                data: env['rack.request.form_hash'] })
    end

    def after
      if response_status
        log_api(:info,
                'api-response',
                { request_id: env['action_dispatch.request_id'],
                  status: response_status,
                  response_body: })
      end
      @app_response # this must return @app_response or nil
    end

    private

    def request_data
      @request_data ||= env['rack.request.form_hash'] || {}
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

      @app_response.first.to_s
    end

    def response_body
      return if @app_response.blank?

      JSON.parse(@app_response[2].first)
    rescue JSON::ParserError => e
      log_api(:error,
              'api-response-body',
              "Error parsing API response body: \n#{@app_response[2].first}",
              e)
    end

    def log_api(level, type, message, error = nil)
      LogStuff.send(
        level.to_sym,
        type:,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message
      end
    end
  end
end
