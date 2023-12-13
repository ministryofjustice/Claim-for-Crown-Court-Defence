require 'webmock/cucumber'

Before('@stub_feedback_success') do
  stub_request(:post, %r{\A#{feedback_service_url}} )
    .and_return(status: 201, body: successful_feedback_body.to_json)
end

Before('@stub_feedback_failure') do
  stub_request(:post, %r{\A#{feedback_service_url}} )
    .and_return(status: 500, body: unsuccessful_feedback_body.to_json)
end

Before('@stub_bug_report_success') do
  stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
  .and_return(status: 201, body: { item: {} }.to_json)
end

Before('@stub_bug_report_failure') do
  stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
    .and_return(status: 500, body: { error: 'Unsuccessful' }.to_json)
end

def successful_feedback_body
  if Settings.zendesk_feedback_enabled?
    # Zendesk
    { item: {} }.to_json
  else
    # Survey Monkey
    { id: '123' }.to_json
  end
end

def unsuccessful_feedback_body
  if Settings.zendesk_feedback_enabled?
    # Zendesk
    { error: 'Unsuccessful' }.to_json
  else
    # Survey Monkey
    { error: { id: '1050' } }.to_json
  end
end

def feedback_service_url
  if Settings.zendesk_feedback_enabled?
    "https://ministryofjustice.zendesk.com/api/v2/.*"
  else
    "https://api.surveymonkey.com/v3/.*"
  end
end
