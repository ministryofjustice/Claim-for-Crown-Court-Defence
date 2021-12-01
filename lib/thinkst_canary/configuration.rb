module ThinkstCanary
  class HttpError < StandardError; end

  class Configuration
    attr_accessor :account_id, :auth_token

    def connection
      @connection ||= Faraday.new(root_url)
    end

    def post_query(url, params: {}, auth: true)
      params[:auth_token] = auth_token if auth
      response = connection.post(url, **params)
      raise HttpError, "HTTP status #{response.status}" unless response.success?
      JSON.parse(response.body)
    end

    private

    def root_url
      "https://#{account_id}.canary.tools/"
    end
  end
end
