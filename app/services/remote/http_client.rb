module Remote
  class HttpClient
    cattr_accessor :instance, :logger, :base_url, :api_key, :read_timeout, :open_timeout
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
    end

    def get(path, options = {})
      execute_request(:get, path, options)
    end

    private

    def build_endpoint(path)
      [self.base_url, path].join('/') + '?' + {api_key: self.api_key}.to_query
    end

    def execute_request(method, path, options = {})
      endpoint = build_endpoint(path)
      response = Caching::ApiRequest.cache(endpoint, ttl: options[:ttl]) do
        RestClient::Request.execute(
            method: method, url: endpoint, read_timeout: self.read_timeout, open_timeout: self.open_timeout)
      end
      JSON.parse(response)
    end
  end
end
