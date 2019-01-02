require 'performance_platform/data_set'
require 'performance_platform/url_builder'
require 'performance_platform/submission'
require 'performance_platform/reports'
require 'performance_platform/configuration'

module PerformancePlatform
  class << self
    def root
      # spec = Gem::Specification.find_by_name("performance-platform")
      # spec.gem_dir
    end

    def report(name)
      report = Reports.new.call(name)
      Submission.new(report)
    rescue NoMethodError
      raise "#{name} is not present in config/performance_platform.yml"
    end

    attr_writer :configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def reset
      @configuration = Configuration.new
    end
  end
end
