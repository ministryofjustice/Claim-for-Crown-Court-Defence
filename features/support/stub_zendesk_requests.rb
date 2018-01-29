require 'webmock/cucumber'

Before('@stub_zendesk_request') do
  @called_zendesk = stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z} )
end
