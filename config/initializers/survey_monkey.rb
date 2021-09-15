SurveyMonkey.configure do |config|
  config.root_url = 'https://api.eu.surveymonkey.com/v3/'
  # Set SURVEY_MONKEY_AUTHORIZATION_BEARER in .env.development
  # TODO: Set in kubernetes_deploy/*/secrets.yaml
  config.bearer = ENV['SURVEY_MONKEY_AUTHORIZATION_BEARER']
  config.collector_id = 330140894

  # TODO: Set the correct survey pages, questions and answers
  config.register_page(
    :feedback, 25473840,
    tasks: { id: 60742936, answers: { yes: 505487571, no: 505487572, partially: 505487573 } },
    ratings: {
      id: 789,
      answers: {
        very_satisfied: 6123451,
        satisfied: 6123452,
        neither_satisfied_nor_dissatisfied: 6123453,
        dissatisfied: 6123454,
        very_dissatisfied: 6123455
      }
    },
    reasons: { id: 234, answers: { lgfs_claim: 7123451, agfs_claim: 7123452, other: 7123453 } },
    # TODO: Allow for free text answer
    # other_reason: { id: 567, answer: :text }
  )
end
