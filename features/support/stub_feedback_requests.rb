require 'webmock/cucumber'

Before('@stub_feedback_success') do
  if Settings.zendesk_feedback_enabled?
    stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
      .and_return(status: 201, body: { id: '123' }.to_json)
  else
    stub_request(:post, %r{\Ahttps://api.eu.surveymonkey.com/v3/.*} )
      .and_return(status: 201, body: { id: '123' }.to_json)
  end
end

Before('@stub_feedback_failure') do
  if Settings.zendesk_feedback_enabled?
    stub_request(:post, %r{\Ahttps://ministryofjustice.zendesk.com/api/v2/.*} )
      .and_return(status: 500, body: { error: { id: '1050' } }.to_json)
  else
    stub_request(:post, %r{\Ahttps://api.eu.surveymonkey.com/v3/.*} )
    .and_return(status: 500, body: { error: { id: '1050' } }.to_json)
  end
end
