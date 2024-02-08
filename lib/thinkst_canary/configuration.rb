module ThinkstCanary
  class HttpError < StandardError; end
  class HttpUnknownAction < StandardError; end

  class Configuration
    attr_accessor :account_id, :auth_token

    ALLOWED_ACTIONS = %i[post get delete].freeze

    def connection
      @connection ||= Faraday.new(root_url) do |f|
        f.request :multipart
        f.request :url_encoded
        f.response :follow_redirects, limit: 5
        f.adapter Faraday.default_adapter
      end
    end

    def query(action, url, params: {}, auth: true, json: true)
      response = raw_query(action, url, full_params(params, auth))
      raise HttpError, "HTTP status #{response.status}\nResponse body:\n#{response.body}" unless response.success?
      json ? JSON.parse(response.body) : response.body
    end

    private

    def root_url
      "https://#{account_id}.canary.tools/"
    end

    def raw_query(action, url, params)
      raise HttpUnknownAction, "Unknown action: '#{action}'" unless ALLOWED_ACTIONS.include?(action)
      return connection.post(url, **params) if action == :post

      connection.send(action, url, params)
    end

    def full_params(params, auth)
      return params.merge(auth_token:) if auth

      params
    end
  end
end
