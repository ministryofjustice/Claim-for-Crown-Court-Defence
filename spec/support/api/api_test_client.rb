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
$LOAD_PATH << Rails.root.join('spec', 'support', 'api', 'claims')
require 'debuggable'
require 'advocate_claim_test/final'
require 'advocate_claim_test/hardship'
require 'advocate_claim_test/interim'
require 'advocate_claim_test/supplementary'
require 'litigator_claim_test/final'
require 'litigator_claim_test/hardship'
require 'litigator_claim_test/interim'
require 'litigator_claim_test/transfer'

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
    AdvocateClaimTest::Final.new(client: self).test_creation!
    AdvocateClaimTest::Interim.new(client: self).test_creation!
    AdvocateClaimTest::Supplementary.new(client: self).test_creation!
    AdvocateClaimTest::Hardship.new(client: self).test_creation!
    LitigatorClaimTest::Final.new(client: self).test_creation!
    LitigatorClaimTest::Interim.new(client: self).test_creation!
    LitigatorClaimTest::Transfer.new(client: self).test_creation!
    LitigatorClaimTest::Hardship.new(client: self).test_creation!
  end

  def failure
    !@success
  end

  def post_to_endpoint(resource, payload)
    debug("Payload:\n#{payload}\n")

    endpoint(resource:, prefix: EXTERNAL_USER_PREFIX) do |e|
      response = e.post(payload.to_json, content_type: :json, accept: :json)
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
    endpoint(resource:, prefix: 'api', api_key:, **params) do |e|
      body = Caching::ApiRequest.cache(e.url) do
        e.get.tap { |response| handle_response(response, resource) }
      end
      JSON.parse(body)
    end
  rescue JSON::ParserError
    {}
  end

  private

  def endpoint(resource:, prefix:, **params, &)
    query_params = '?' + params.to_query
    url = [api_root_url, prefix, resource].join('/') + query_params
    debug("POSTING TO #{url}")

    yield RestClient::Resource.new(url)
  end

  def handle_response(response, resource)
    debug("Code: #{response.code}")
    debug("Body:\n#{response.body}\n")
    return if /^2/.match?(response.code.to_s)

    @success = false
    @full_error_messages << "#{resource} Endpoint raised error - #{response}"
  end

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end
end
