require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    erb: true,
    exclusive: true,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:api_key)]
  }

  # Do not capture requests other than to the API endpoints
  c.ignore_request do |request|
    !URI(request.uri).path.start_with?('/api/')
  end
end
