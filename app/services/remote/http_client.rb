module Remote
  class HttpClient
    include Singleton

    attr_accessor :api_key, :timeout, :open_timeout, :headers
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
      response = Caching::ApiRequest.cache(endpoint) do
        RestClient::Request.execute(method:, url: endpoint, timeout:, open_timeout:, headers:)
      end
      JSON.parse(response, symbolize_names: true)
    end
  end
end
