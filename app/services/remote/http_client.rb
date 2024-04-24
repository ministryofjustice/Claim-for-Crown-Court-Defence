module Remote
  class HttpClient
    include Singleton

    attr_accessor :api_key, :timeout, :open_timeout
    attr_reader :logger
    attr_writer :base_url

    def self.configure
      yield(instance)
    end

    def logger=(log)
      @logger = log
      @connection = nil
    end

    def base_url
      @base_url ||= Settings.remote_api_url
    end

    def get(path, **)
      params = { api_key: }.merge(**)
      response = Caching::APIRequest.cache("#{path}?#{params.to_query}") { connection.get(path, params) }
      JSON.parse(response, symbolize_names: true)
    end

    private

    def connection
      # We have added the headers { 'X-Forwarded-Proto': 'https', 'X-Forwarded-Ssl': 'on' } in order to bypass the config.force_ssl
      # This is because this API call is now being routed internally and does not access the internet. HTTPS is not supported within the Kubernetes Cluster.
      # TODO: Decouple these headers from the HTTP Client or Find a new solution to route these internal calls without being affected by SSL/TLS.
      @connection ||= Faraday.new(
        url: base_url,
        request: { open_timeout:, timeout: },
        headers: { 'X-Forwarded-Proto': 'https', 'X-Forwarded-Ssl': 'on' }
      ) do |conn|
        # See https://github.com/lostisland/faraday/blob/main/docs/middleware/included/logging.md
        conn.response :logger, logger, { headers: true, bodies: false, errors: true }
      end
    end
  end
end
