# Module to configure maintenance mode for the entire
# app.
module MaintenanceMode
  class Configuration
    attr_accessor :enabled, :retry_after

    def initialize
      @enabled = false
      @retry_after = 3600
    end

    def enabled?
      enabled
    end
  end

  class << self
    attr_writer :configuration
    delegate :retry_after, :enabled?, to: :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end
  end
end
