require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    erb: true,
    exclusive: true,
    allow_playback_repeats: true,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:api_key, :key)]
  }

  # Do not capture requests other than to the API endpoints
  c.ignore_request do |request|
    URI(request.uri).path == "/__identify__" ||
    (!URI(request.uri).path.start_with?('/api/') &&
      !URI(request.uri).path =~ /maps.googleapis.com/)
  end

  c.filter_sensitive_data('<GOOGLE_API_KEY>') { Rails.application.secrets.google_api_key }
end
