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

  # Enable VCR logging using, for example,
  #  `VCR_DEBUG=1 rspec ./spec/controllers/external_users/claims_controller_spec.rb`
  c.debug_logger = File.open(c.cassette_library_dir + '/vcr_debug.log', 'w') if ENV['VCR_DEBUG']

  # Ignore requests other than to the API endpoints, LAA fee calculator and google maps
  c.ignore_request do |request|
    URI(request.uri).path == "/__identify__" ||
    (!URI(request.uri).path.start_with?('/api/') &&
      !URI(request.uri).path =~ /maps.googleapis.com/ &&
      !URI(request.uri).path =~ /apilayer.net/)
  end

  c.filter_sensitive_data('<GOOGLE_API_KEY>') { Rails.application.secrets.google_api_key }
  c.filter_sensitive_data('<CURRENCY_API_KEY>') { Rails.application.secrets.currency_api_key }
end

# use `VCR_OFF=true cucumber|rspec` too turn off vcr
VCR.turn_off!(:ignore_cassettes => true) if ENV['VCR_OFF']

# custom VCR request matcher to match request based on
# path and query but not host because laa-fee-calculator
# host could change and responses are path and query specific
path_query_matcher = lambda do |request_1, request_2|
  uri_1 = URI(request_1.uri)
  uri_2 = URI(request_2.uri)
  [uri_1.path == uri_2.path, uri_1.query == uri_2.query].all?
end

# Create VCR cassettes for any specs with a :fee_calc_vcr tag
# in the cassette library under a directory structure
# mirroring the specs'.
RSpec.configure do |config|
  config.around(:each, [:fee_calc_vcr, :currency_vcr]) do |example|
    if VCR.turned_on?
      cassette = Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
      VCR.use_cassette(cassette, :record => :new_episodes, :match_requests_on => [:method, path_query_matcher]) do
        example.run
      end
    else
      example.run
    end
  end
end
