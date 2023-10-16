class DistanceCalculatorService
  class Directions
    def initialize(origin, destination)
      @origin = origin
      @destination = destination
    end

    def max_distance
      routes.distances.max
    end

    private

    def routes
      @routes ||= DistanceCalculatorService::GoogleAPI.new(@origin, @destination)
    end
  end
end
