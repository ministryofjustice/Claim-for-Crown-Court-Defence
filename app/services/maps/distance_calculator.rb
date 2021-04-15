module Maps
  class DistanceCalculator
    GOOGLE_DIRECTIONS_API = 'https://maps.google.com/maps/api/directions/json'.freeze

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
      result = Maps::DirectionsResult.new(JSON.parse(directions(**params).body))
      result.max_distance
    rescue StandardError => e
      log("Failed to calculating distance form #{origin} to #{destination}", error: e, level: :error)
      nil
    end

    private

    def directions(params = {})
      RestClient.get GOOGLE_DIRECTIONS_API, params: params
    end

    def query_options
      default_options.merge(options)
    end

    def default_options
      {
        region: 'uk',
        alternatives: true,
        key: Rails.application.secrets.google_api_key
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
