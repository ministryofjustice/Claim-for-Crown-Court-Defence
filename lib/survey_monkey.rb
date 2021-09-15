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
  end

  class UnregisteredPage < StandardError; end
  class UnregisteredQuestion < StandardError; end
  class UnregisteredResponse < StandardError; end

  def self.page_by_name(name)
    configuration.pages.page_by_name(name)
  end
end
