require 'survey_monkey/answers'
require 'survey_monkey/configuration'
require 'survey_monkey/page_collection'
require 'survey_monkey/page'
require 'survey_monkey/response'

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

    def connection
      @configuration.connection
    end

    def collector_id
      @configuration.collector_id
    end

    def log(level, message)
      return if @configuration.logger.nil?

      @configuration.logger.send(level, "[SurveyMonkey] #{message}")
    end
  end

  class UnregisteredPage < StandardError; end
  class UnregisteredQuestion < StandardError; end
  class UnregisteredResponse < StandardError; end
end
