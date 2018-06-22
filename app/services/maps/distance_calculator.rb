require 'googlemaps/services/client'
require 'googlemaps/services/directions'

module Maps
  class DistanceCalculator
    include GoogleMaps::Services

    def self.call(origin, destination, options = {})
      new(origin, destination, options).call
    end

    attr_reader :origin, :destination, :options

    def initialize(origin, destination, options = {})
      @origin = origin
      @destination = destination
      @options = options || {}
    end

    def call
      params = query_options.merge(origin: origin, destination: destination)
      result = Maps::DirectionsResult.new(directions.query(params))
      result.max_distance
    rescue StandardError => e
      Rails.logger.error "Error calculating distance #{e.message}"
      nil
    end

    private

    def client
      GoogleClient.new(key: Rails.application.secrets.google_api_key, response_format: :json)
    end

    def directions
      Directions.new(client)
    end

    def query_options
      default_options.merge(options)
    end

    def default_options
      {
        region: 'uk',
        alternatives: true
      }
    end
  end
end
