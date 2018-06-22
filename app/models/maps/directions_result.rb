module Maps
  class DirectionsResult
    def initialize(response)
      @response = response
    end

    def max_distance
      return if routes.empty?
      distances.max
    end

    def distances
      @distances ||= map_distances
    end

    private

    attr_reader :response
    alias routes response

    # NOTE: Distance values are in meters
    # Leaving formatting up to the services that require it
    def map_distances
      routes.flat_map do |route|
        route['legs'].map { |leg| leg['distance']['value'] }
      end
    rescue StandardError => e
      Rails.logger.error "[MAPS] Error mapping directions distance results: #{e.message}"
      []
    end
  end
end
