Rails.application.reloader.to_prepare do
  SurveyMonkey.configure do |config|
    config.root_url = 'https://api.eu.surveymonkey.com/v3/'
    config.bearer = Settings.survey_monkey_bearer_token.to_s
    config.logger = Rails.logger
    config.verbose_logging = true

    config.register_collector(:court_data, id: ENV['SURVEY_MONKEY_COURT_DATA_COLLECTOR_ID'])

    court_data_page = CourtDataForm.new
    config.register_page(court_data_page.name, id: court_data_page.id, collector: court_data_page.collector, questions: court_data_page.template)
  end
end
