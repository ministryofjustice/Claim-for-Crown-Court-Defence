require 'uri'
require 'net/http'
require 'yaml'
require 'json'
#
# Client for the API to be used with the test suite
#
module ApiClient
  module V1

    PARSER     = JSON
    SERIALIZER = YAML

    protected
    
    def fetch(route)
      PARSER.parse(perform_get(route).body)
    end

    def send(route, data)
      PARSER.parse(perform_post(route, data).body)
    end

    private

    def http_get
      Proc.new { |uri| Net::HTTP.get_response(uri) }
    end

    def http_post
      Proc.new { |uri, data| Net::HTTP.post_form(uri, data) }
    end

    def perform_get(route)
      perform_request(http_get, build_uri(route), nil)     
    end

    def perform_post(route, data)
      perform_request(http_post, build_uri(route), data)   
    end

    def perform_request(http_method, uri, data)
      res  = http_method.call(uri, data)

      raise FailureResponse.new(res) if res.code != '200'

      res

    rescue Errno::ECONNREFUSED
      raise ConnectionRefused.new(uri)
    end

    def build_uri(route)
      URI.parse([
        Settings.api_client.host, 
        Settings.api_client.base_path, 
        route
      ].join('/'))
    end

    class ConnectionRefused < StandardError
      def initialize(uri_s)
        super(
          "The connection was refused by the REST API server @ " + 
          "#{uri_s}, ensure that it is running"
        )
      end
    end

    class FailureResponse < StandardError
      def initialize(res)
        super(
          "The REST API responsed with non-success code: #{res.code}" + 
          "\nDetails: #{res.body}"
        )
      end
    end
  end
end
