class DistanceCalculatorService
  class Directions
    GOOGLE_DIRECTIONS_API = 'https://maps.google.com/maps/api/directions/json'.freeze

    delegate :max_distance, to: :results

    def initialize(origin, destination, options = {})
      @origin = origin
      @destination = destination
      @options = options
    end

    private

    def results
      @results ||= DistanceCalculatorService::DirectionsResult.new(routes)
    end

    def routes
      @routes ||= begin
        JSON.parse(directions.body)['routes']
      rescue StandardError => e
        log("Failed to calculating distance form #{@origin} to #{@destination}", error: e, level: :error)
        []
      end
    end

    def directions
      params = query_options.merge(origin: @origin, destination: @destination)
      RestClient.get GOOGLE_DIRECTIONS_API, params: params
    end

    def query_options
      default_options.merge(@options)
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
        class: 'DistanceCalculatorService::Directions',
        action: 'call',
        origin: @origin,
        destination: @destination,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message
      end
    end
  end
end
