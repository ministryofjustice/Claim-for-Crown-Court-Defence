module Remote
  class HttpClient
    cattr_accessor :instance, :logger, :base_url, :api_key, :timeout, :open_timeout
    private_class_method :new

    class << self
      def configure
        yield(self)
      end

      def current
        self.instance ||= new
      end

      def logger=(log)
        @@logger = RestClient.log = log
      end

      def base_url
        @@base_url ||= Settings.remote_api_url
      end
    end

    def get(path, query = {})
      execute_request(:get, path, query)
    end

    private

    def build_endpoint(path, query)
      [self.class.base_url, path].join('/') + '?' + { api_key: api_key }.merge(query).to_query
    end

    def execute_request(method, path, query)
      endpoint = build_endpoint(path, query)
      response = Caching::ApiRequest.cache(endpoint) do
        RestClient::Request.execute(method: method, url: endpoint, timeout: timeout, open_timeout: open_timeout)
      end
      JSON.parse(response, symbolize_names: true)
    end
  end
end
