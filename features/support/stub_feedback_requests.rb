require 'webmock/cucumber'

SURVEY_MONKEY_URL = "https://api.eu.surveymonkey.com/v3/.*"
ZENDESK_URL = "https://ministryofjustice.zendesk.com/api/v2/.*"
SUCCESSFUL_SURVEY_MONKEY_BODY = { id: '123' }
UNSUCCESSFUL_SURVEY_MONKEY_BODY =  { error: { id: '1050' } }
SUCCESSFUL_ZENDESK_BODY = { item: {} }
UNSUCCESSFUL_ZENDESK_BODY = { error: 'Unsuccessful' }

Before('@stub_survey_monkey_feedback_success') do
  stub_request(:post, %r{\A#{SURVEY_MONKEY_URL}} )
    .and_return(status: 201, body: SUCCESSFUL_SURVEY_MONKEY_BODY.to_json)
end

Before('@stub_zendesk_feedback_success') do
  stub_request(:post, %r{\A#{ZENDESK_URL}} )
    .and_return(status: 201, body: SUCCESSFUL_ZENDESK_BODY.to_json)
end

Before('@stub_survey_monkey_feedback_failure') do
  stub_request(:post, %r{\A#{SURVEY_MONKEY_URL}} )
    .and_return(status: 500, body: UNSUCCESSFUL_SURVEY_MONKEY_BODY.to_json)
end

Before('@stub_zendesk_feedback_failure') do
  stub_request(:post, %r{\A#{ZENDESK_URL}} )
    .and_return(status: 500, body: UNSUCCESSFUL_ZENDESK_BODY.to_json)
end

Before('@stub_bug_report_success') do
  stub_request(:post, %r{\A#{ZENDESK_URL}} )
  .and_return(status: 201, body: SUCCESSFUL_ZENDESK_BODY.to_json)
end

Before('@stub_bug_report_failure') do
  stub_request(:post, %r{\A#{ZENDESK_URL}} )
    .and_return(status: 500, body: UNSUCCESSFUL_ZENDESK_BODY.to_json)
end
