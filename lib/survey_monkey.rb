require 'survey_monkey/configuration'

module SurveyMonkey
  class << self
    delegate :connection, to: :@configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def page_by_name(name) = configuration.pages[name]

    def collector_by_name(name) = configuration.collectors[name]

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
