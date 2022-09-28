# class used to smoke test the Restful API
#
# The claim creation process uses the dropdown data endpoints
# thereby double checking that those endpoints are working and
# their values are valid for claim creation or associated records.
#
# example:
# ---------------------------------------
#   api_client = ApiTestClient.new()
#   api_client.run
#   if api_client.failure
#     puts "failed"
#     puts api_client.full_error_messages.join("/n")
#   end
# ---------------------------------------
#
# To debug any test:
#
# debug('my debug statement', :red)
#

require 'caching/api_request'
require 'rest-client'
Dir[Rails.root.join('spec', 'support', 'api', 'claims', '*.rb')].each { |file| require file }

class ApiTestClient
  include Debuggable

  attr_reader :success, :full_error_messages, :messages

  EXTERNAL_USER_PREFIX = 'api/external_users'.freeze

  def initialize
    @full_error_messages = []
    @messages = []
    @success = true
  end

  def run
    AdvocateClaimTest.new(client: self).test_creation!
    AdvocateInterimClaimTest.new(client: self).test_creation!
    AdvocateSupplementaryClaimTest.new(client: self).test_creation!
    AdvocateHardshipClaimTest.new(client: self).test_creation!
    LitigatorFinalClaimTest.new(client: self).test_creation!
    LitigatorInterimClaimTest.new(client: self).test_creation!
    LitigatorTransferClaimTest.new(client: self).test_creation!
    LitigatorHardshipClaimTest.new(client: self).test_creation!
  end

  def failure
    !@success
  end

  def post_to_endpoint(resource, payload)
    endpoint = fetch_endpoint(resource:, prefix: EXTERNAL_USER_PREFIX)
    debug("Payload:\n#{payload}\n")

    endpoint.post(payload.to_json, content_type: :json, accept: :json) do |response, _request, _result|
      debug("Code: #{response.code}")
      debug("Body:\n#{response.body}\n")
      handle_response(response, resource)
      JSON.parse(response.body)
    end
  rescue JSON::ParserError
    {}
  end

  #
  # don't raise exceptions but, instead, return the
  # response for analysis.
  #
  def get_dropdown_endpoint(resource, api_key, **params)
    endpoint = fetch_endpoint(resource:, prefix: 'api', api_key:, **params)

    JSON.parse(Caching::ApiRequest.cache(endpoint.url) do
      endpoint.get do |response, _request, _result|
        handle_response(response, resource)
        response
      end
    end)
  rescue JSON::ParserError
    {}
  end

  private

  def fetch_endpoint(resource:, prefix:, **params)
    query_params = '?' + params.to_query
    RestClient::Resource.new([api_root_url, prefix, resource].join('/') + query_params).tap do |endpoint|
      debug("POSTING TO #{endpoint}")
    end
  end

  def handle_response(response, resource)
    return if /^2/.match?(response.code.to_s)
    @success = false
    @full_error_messages << "#{resource} Endpoint raised error - #{response}"
  end

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end
end
