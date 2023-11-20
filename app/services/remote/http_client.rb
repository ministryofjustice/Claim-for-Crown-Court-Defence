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
      @logger = RestClient.log = log
    end

    def base_url
      @base_url ||= Settings.remote_api_url
    end

    def get(path, **query)
      execute_request(:get, path, **query)
    end

    private

    def build_endpoint(path, **query)
      [base_url, path].join('/') + '?' + { api_key: }.merge(**query).to_query
    end

    def execute_request(method, path, **query)
      endpoint = build_endpoint(path, **query)
      response = Caching::APIRequest.cache(endpoint) do
        # We have added the headers { 'X-Forwarded-Proto': 'https', 'X-Forwarded-Ssl': 'on' } in order to bypass the config.force_ssl
        # This is because this API call is now being routed internally and does not access the internet. HTTPS is not supported within the Kubernetes Cluster.
        # TODO: Decouple these headers from the HTTP Client or Find a new solution to route these internal calls without being affected by SSL/TLS.
        RestClient::Request.execute(method:, url: endpoint, timeout:, open_timeout:,
                                    headers: { 'X-Forwarded-Proto': 'https', 'X-Forwarded-Ssl': 'on' })
      end
      JSON.parse(response, symbolize_names: true)
    end
  end
end
