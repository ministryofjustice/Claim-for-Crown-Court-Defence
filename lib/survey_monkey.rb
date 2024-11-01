require 'survey_monkey/configuration'

module SurveyMonkey
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def page_by_name(name)
      configuration.pages.page_by_name(name)
    end

    def collector_by_name(name) = configuration.collectors[name]

    def connection
      @configuration.connection
    end

    def log(level, message)
      return if @configuration.logger.nil?

      @configuration.logger.send(level, "[SurveyMonkey] #{message}")
    end
  end

  class UnregisteredPage < StandardError; end
  class UnregisteredCollector < StandardError; end
  class UnregisteredQuestion < StandardError; end
  class UnregisteredResponse < StandardError; end
  class MismatchedCollectors < StandardError; end
end
