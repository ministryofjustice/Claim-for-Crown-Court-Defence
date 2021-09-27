SurveyMonkey.configure do |config|
  config.root_url = 'https://api.eu.surveymonkey.com/v3/'
  config.bearer = ENV['SURVEY_MONKEY_BEARER_TOKEN']
  config.collector_id = ENV['SURVEY_MONKEY_COLLECTOR_ID']
  config.logger = Rails.logger
  config.verbose_logging = true

  page = FeedbackForm.new
  config.register_page(page.name, page.id, **page.template)
end
