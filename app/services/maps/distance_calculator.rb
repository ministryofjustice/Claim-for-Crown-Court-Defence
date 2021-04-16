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
      log("Calculating distance from #{origin} to #{destination}")
      direction_result.max_distance
    rescue StandardError => e
      log("Failed to calculate distance from #{origin} to #{destination}", error: e, level: :error)
      nil
    end

    private

    def direction_result
      params = query_options.merge(origin: origin, destination: destination)
      Maps::DirectionsResult.new(directions_client.query(**params))
    end

    def directions_client
      Directions.new(google_client)
    end

    def google_client
      GoogleClient.new(key: Rails.application.secrets.google_api_key, response_format: :json)
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

    def log(message, error: nil, level: :info)
      LogStuff.send(
        level,
        class: 'Maps::DistanceCalculator',
        action: 'call',
        origin: origin,
        destination: destination,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message.prepend('[MAPS] ')
      end
    end
  end
end
