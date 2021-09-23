SurveyMonkey.configure do |config|
  config.root_url = 'https://api.eu.surveymonkey.com/v3/'
  config.bearer = ENV['SURVEY_MONKEY_BEARER_TOKEN']
  config.collector_id = ENV['SURVEY_MONKEY_COLLECTOR_ID']
  config.logger = Rails.logger
  config.verbose_logging = true

  config.register_page(
    :feedback, 25473840,
    tasks: {
      id: 60742936,
      format: :radio,
      answers: {
        '3' => 505487572, # Yes
        '2' => 505487573, # No
        '1' => 505487574  # Partially
      }
    },
    ratings: {
      id: 60742964,
      format: :radio,
      answers: {
        '5' => 505488046, # Very satisfied
        '4' => 505488047, # Satisfied
        '3' => 505488048, # Neither satisfied nor dissatisified
        '2' => 505488049, # Dissatisfied
        '1' => 505488050  # Very dissatisfied
      }
    },
    comments: { id: 60742937, format: :text },
    reasons: {
      id: 60745386,
      format: :checkboxes,
      answers: {
        '3' => 505511336, # Submit an LGFS claim
        '2' => 505511337, # Submit an AGFS claim
        '1' => { id: 505511338, other: true } # Other reasons
      }
    }
  )
end
