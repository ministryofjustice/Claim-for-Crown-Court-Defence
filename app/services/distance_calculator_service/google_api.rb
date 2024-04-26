class DistanceCalculatorService
  class GoogleAPI
    def initialize(origin, destination)
      @origin = origin
      @destination = destination
    end

    def distances
      @distances ||= routes.map { |route| sum_legs route['legs'] }.select(&:positive?)
    end

    private

    def sum_legs(legs)
      return 0 if legs.nil?

      legs.filter_map { |leg| leg.dig('distance', 'value') }.sum
    end

    def routes
      @routes ||= begin
        JSON.parse(directions)['routes']
      rescue StandardError => e
        log("Failed to calculate distance from #{@origin} to #{@destination}", error: e, level: :error)
        []
      end
    end

    def directions
      @directions ||= Faraday.get(Rails.application.config.google_directions_api_url, **params).body
    end

    def params
      @params ||= {
        region: 'uk',
        alternatives: true,
        key: Settings.google_api_key,
        origin: @origin,
        destination: @destination
      }
    end

    def log(message, error: nil, level: :info)
      LogStuff.send(
        level,
        class: 'DistanceCalculatorService::GoogleApi',
        action: 'routes',
        origin: @origin,
        destination: @destination,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message
      end
    end
  end
end
