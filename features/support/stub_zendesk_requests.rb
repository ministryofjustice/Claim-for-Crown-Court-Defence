Before('@stub_zendesk_request') do
  stub_request(:post, "https://ministryofjustice.zendesk.com/api/v2/tickets")
end
