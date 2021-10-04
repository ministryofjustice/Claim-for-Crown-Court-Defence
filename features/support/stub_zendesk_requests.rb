require 'webmock/cucumber'

Before('@stub_zendesk_request') do
  stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z})
    .to_return(status: 200, body: "stubbed response", headers: {})
end
