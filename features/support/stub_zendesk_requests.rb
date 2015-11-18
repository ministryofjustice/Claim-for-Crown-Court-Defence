Before('@stub_zendesk_request') do
  stub_request(:post, %r{\Ahttps://.*ministryofjustice.zendesk.com/api/v2/tickets\z} )
end
