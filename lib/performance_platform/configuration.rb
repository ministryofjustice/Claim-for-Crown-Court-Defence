# frozen_string_literal: true

module PerformancePlatform
  class Configuration
    PERFORMANCE_PLATFORM_ENDPOINT = 'https://www.performance.service.gov.uk/data'

    attr_accessor :root_url, :service, :group

    def initialize
      @root_url = root_url || PERFORMANCE_PLATFORM_ENDPOINT
      @service = service
      @group = group
    end
  end
end
