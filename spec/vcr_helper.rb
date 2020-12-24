require 'vcr'

VCR.configure do |c|
  # place all cassettes in this directory
  c.cassette_library_dir = 'vcr/cassettes'

  # use webmock to hook into and replay requests
  c.hook_into :webmock

  # enable rspec :vcr tag for autonmatically named cassettes. needed??
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    erb: true,
    exclusive: true,
    allow_playback_repeats: true,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:api_key, :key)]
  }

  # Enable VCR logging using, for example:
  # `VCR_DEBUG=1 rspec ./spec/controllers/external_users/claims_controller_spec.rb`
  c.debug_logger = File.open(c.cassette_library_dir + '/vcr_debug.log', 'w') if ENV['VCR_DEBUG']

  # Ignore requests to
  # - capybara-selenium
  # - chrome browser/selenium requests to localhost port on which it runs
  # Do not ignore requests to:
  # - CCCD API endpoints, LAA fee calculator and google maps
  #
  c.ignore_request do |request|
    uri = URI(request.uri)
    [
      uri.path == '/__identify__',
      [
        !uri.path.start_with?('/api/'),
        !uri.path =~ /maps.googleapis.com/,
        !uri.path =~ /apilayer.net/
      ].all?,
      [
        uri.host.eql?('127.0.0.1'),
        (9515..9999).include?(uri.port)
      ].all?
    ].any?
  end

  # The `webdriver` gem's requests to download drivers can be blocked by VCR
  # without this.
  # see https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
  # for details
  #
  c.ignore_hosts(
    'chromedriver.storage.googleapis.com',
    'github.com/mozilla/geckodriver/releases',
    'selenium-release.storage.googleapis.com',
    'developer.microsoft.com/en-us/microsoft-edge/tools/webdriver'
  )

  # replace sensitive data in cassettes with placeholder and apply secrets on the fly
  c.filter_sensitive_data('<GOOGLE_API_KEY>') { Rails.application.secrets.google_api_key }
  c.filter_sensitive_data('<CURRENCY_API_KEY>') { Rails.application.secrets.currency_api_key }

  # custom VCR request matcher to match request based on
  # path and query but not host because laa-fee-calculator
  # host could change and responses are path and query specific
  #
  c.register_request_matcher :path_query_matcher do |request_1, request_2|
    uri_1 = URI(request_1.uri)
    uri_2 = URI(request_2.uri)
    [uri_1.path == uri_2.path, uri_1.query == uri_2.query].all?
  end
end

# Turn off vcr from the command line, for example:
# `VCR_OFF=true cucumber|rspec`
VCR.turn_off!(:ignore_cassettes => true) if ENV['VCR_OFF']

# Create VCR cassettes for any specs with a :fee_calc_vcr tag
# in the cassette library under a directory structure
# mirroring the specs'.
RSpec.configure do |config|
  config.around(:each, [:fee_calc_vcr, :currency_vcr]) do |example|
    if VCR.turned_on?
      cassette = Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
      VCR.use_cassette(cassette, :record => :new_episodes, :match_requests_on => [:method, :path_query_matcher]) do
        example.run
      end
    else
      example.run
    end
  end
end
