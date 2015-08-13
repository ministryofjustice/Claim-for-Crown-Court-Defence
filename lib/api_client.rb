require 'uri'
require 'net/http'
require 'yaml'
require 'json'
require 'ostruct'
#
# Client for the API to be used with the test suite
#
module ApiClient
  module V1

    SETTINGS_FILE = Rails.root.join('config', 'settings.yml')
    PARSER        = JSON

    protected
    
    def perform_get(route)
      uri_s = [host, base_path, route].join('/')
      Net::HTTP.get_response(URI.parse(uri_s))
    end

    def perform_post(route)
    end

    def host
      settings['api_client']['host']
    end

    def base_path
      settings['api_client']['base_path']
    end

    private

    def settings
      @settings ||= YAML.load(File.read(SETTINGS_FILE))
    end
  end
end
