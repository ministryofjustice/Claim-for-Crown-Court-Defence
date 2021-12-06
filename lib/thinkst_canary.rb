module ThinkstCanary
  class << self
    def configuration
      @configuration ||= ThinkstCanary::Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end
