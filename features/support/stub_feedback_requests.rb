require 'webmock/cucumber'

Before('@stub_feedback_success') do
  stub_request(:post, %r{\A#{feedback_service_url}} )
    .and_return(status: 201, body: successful_zendesk_body.to_json)
end

Before('@stub_feedback_failure') do
  stub_request(:post, %r{\A#{feedback_service_url}} )
    .and_return(status: 500, body: unsuccessful_zendesk_body.to_json)
end

Before('@stub_bug_report_success') do
  stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
  .and_return(status: 201, body: successful_zendesk_body.to_json)
end

Before('@stub_bug_report_failure') do
  stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
    .and_return(status: 500, body: unsuccessful_zendesk_body.to_json)
end

def successful_zendesk_body
  { item: {} }.to_json
end

def unsuccessful_zendesk_body
  { error: 'Unsuccessful' }.to_json
end

def feedback_service_url
  if Settings.zendesk_feedback_enabled?
    "https://ministryofjustice.zendesk.com/api/v2/.*"
  else
    "https://api.eu.surveymonkey.com/v3/.*"
  end
end
