require 'vcr'

# custom VCR request matcher to match request based on
# path and query but not host because laa-fee-calculator
# host could change and responses are path and query specific
path_query_matcher = lambda do |request_1, request_2|
  uri_1 = URI(request_1.uri)
  uri_2 = URI(request_2.uri)
  [uri_1.path == uri_2.path, uri_1.query == uri_2.query].all?
end

VCR.configure do |c|
  c.hook_into :webmock
  # TODO: remove all explicit paths from existing features and enable this default
  # c.cassette_library_dir = 'vcr/cassettes/features'
end

VCR.cucumber_tags do |t|
  t.tag '@fee_calc_vcr', match_requests_on: [:method, path_query_matcher]
end
