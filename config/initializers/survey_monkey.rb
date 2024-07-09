Rails.application.reloader.to_prepare do
  SurveyMonkey.configure do |config|
    config.root_url = 'https://api.eu.surveymonkey.com/v3/'
    config.bearer = Settings.survey_monkey_bearer_token.to_s
    config.collector_id = ENV['SURVEY_MONKEY_COLLECTOR_ID']
    config.logger = Rails.logger
    config.verbose_logging = true

    page = FeedbackForm.new
    config.register_page(page.name, page.id, **page.template)
  end
end
