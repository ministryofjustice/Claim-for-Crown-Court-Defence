require 'webmock/cucumber'

Before('@stub_successful_zendesk_request') do
  stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z})
    .to_return(status: 201, body: successful_zendesk_body, headers: { 'Content-Type' => 'application/json'})
end

Before('@stub_failed_zendesk_request') do
  stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z})
    .to_return(status: 403, body: unsuccessful_zendesk_body, headers: { 'Content-Type' => 'application/json'})
end

def successful_zendesk_body
  { item: {} }.to_json
end

def unsuccessful_zendesk_body
  { error: 'RecordInvalid' }.to_json
end
