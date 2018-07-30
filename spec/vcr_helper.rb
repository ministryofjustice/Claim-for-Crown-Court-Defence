require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    erb: true,
    exclusive: true,
    allow_playback_repeats: true,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:api_key)]
  }

  # Enable VCR logging using, for example,
  #  `VCR_DEBUG=1 rspec ./spec/controllers/external_users/claims_controller_spec.rb`
  c.debug_logger = File.open(c.cassette_library_dir + '/vcr_debug.log', 'w') if ENV['VCR_DEBUG']

  # Ignore requests other than to the API endpoints and LAA fee calculator
  c.ignore_request do |request|
    !URI(request.uri).path.start_with?('/api/')
  end
end

# use `VCR_OFF=true rspec` too turn off vcr
VCR.turn_off! if ENV['VCR_OFF']

# Create VCR cassettes for any specs with a :vcr tag
# in the cassette library under a directory structure
# mirroring the specs'.
RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    if VCR.turned_on?
      cassette = Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
      VCR.use_cassette(cassette, :record => :new_episodes) do
        example.run
      end
    else
      example.run
    end
  end
end
