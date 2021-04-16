class DistanceCalculatorService
  class Directions
    GOOGLE_DIRECTIONS_API = 'https://maps.google.com/maps/api/directions/json'.freeze

    def initialize(origin, destination)
      @origin = origin
      @destination = destination
    end

    def max_distance
      routes.distances.max
    end

    private

    def routes
      @routes ||= DistanceCalculatorService::GoogleApi.new(@origin, @destination)
    end
  end
end
