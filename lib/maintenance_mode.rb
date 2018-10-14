# classes for configuring and initialising
# maintenance mode via a class variable.
module MaintenanceMode
  class Configuration
    attr_accessor :enabled

    def initialize
      @enabled = false
      @retry_after = 3600
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def enabled?
      config.enabled
    end
  end
end
