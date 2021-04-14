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
      log("Calculating distance form #{origin} to #{destination}")
      result = Maps::DirectionsResult.new(directions.query(**params))
      result.max_distance
    rescue StandardError => e
      log("Failed to calculating distance form #{origin} to #{destination}", error: e, level: :error)
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

    def log(message, error: nil, level: :info)
      LogStuff.send(
        level,
        class: 'Maps::DistanceCalculator',
        action: 'call',
        origin: origin,
        destination: destination,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message
      end
    end
  end
end
