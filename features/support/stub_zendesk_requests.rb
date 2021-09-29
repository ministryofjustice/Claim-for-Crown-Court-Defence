require 'webmock/cucumber'

Before('@stub_zendesk_request') do
  @called_zendesk = stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z} )
end

Before('@stub_survey_monkey_request') do
  stub_request(:post, %r{\Ahttps://api.eu.surveymonkey.com/v3/collectors/.*/responses\z} ).
    and_returns(status: 201, body: { id: 123 }.to_json)
end
