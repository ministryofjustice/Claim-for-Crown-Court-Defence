require 'uri'
require 'net/http'
require 'yaml'
require 'json'
#
# Client for the API to be used with the test suite
#
module ApiClient
  module V1

    SETTINGS_FILE = Rails.root.join('config', 'settings.yml')
    PARSER        = JSON
    SERIALIZER    = YAML

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
      # Proc.new { |uri, data| Net::HTTP.post(uri, data) }
    end

    def perform_get(route)
      perform_request(http_get, build_uri(route), nil)     
    end

    def perform_post(route, data)
      perform_request(http_post, build_uri(route), data)   
    end

    def perform_request(http_method, uri, data)
      res  = http_method.call(uri, data)
      code = res.code

      raise FailureResponse.new(code) if code != '200'

      res

    rescue Errno::ECONNREFUSED
      raise ConnectionRefused.new(uri_s)
    end

    def settings
      @settings ||= SERIALIZER.load(File.read(SETTINGS_FILE))
    end

    def host
      settings['api_client']['host']
    end

    def base_path
      settings['api_client']['base_path']
    end

    def build_uri(route)
      URI.parse([host, base_path, route].join('/'))
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
      def initialize(status_code)
        super("The REST API responsed with non-success code: #{status_code}")
      end
    end
  end
end
