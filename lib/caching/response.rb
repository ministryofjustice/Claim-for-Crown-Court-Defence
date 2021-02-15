class Caching
  class Response
    attr_accessor :response

    def initialize(response)
      self.response = response
      validate!
    end

    def body
      response.body
    end

    def headers
      response.headers
    end

    def ttl
      return 0 if cache_control.match?('no-cache')
      cache_control[/max-age=([0-9]+)/, 1]
    end

    private

    def cache_control
      headers[:cache_control] || ''
    end

    def validate!
      raise ArgumentError, 'response object must implement a `body` method' unless response.respond_to?(:body)
      raise ArgumentError, 'response object must implement a `headers` method' unless response.respond_to?(:headers)
    end
  end
end
