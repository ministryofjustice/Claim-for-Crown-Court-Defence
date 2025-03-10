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
    path = "#{EXTERNAL_USER_PREFIX}/#{resource}"
    body = payload.to_json
    debug("POSTING TO #{path}")
    debug("Payload:\n#{body}\n")

    response = connection.post(path, body, { 'Content-Type': 'application/json', Accept: 'application/json' })
    handle_response(response, resource)
    JSON.parse(response.body)
  rescue JSON::ParserError
    {}
  end

  #
  # don't raise exceptions but, instead, return the
  # response for analysis.
  #
  def get_dropdown_endpoint(resource, **kwargs)
    path = "api/#{resource}"
    debug("GETTING FROM #{path}")
    debug("Params: #{kwargs}\n")

    body = Caching::APIRequest.cache("#{path}?#{kwargs.to_query}") do
      connection.get(path, **kwargs).tap { |response| handle_response(response, resource) }
    end
    JSON.parse(body)
  rescue JSON::ParserError
    {}
  end

  private

  def connection = @connection ||= Faraday.new(api_root_url)

  def handle_response(response, resource)
    debug("Code: #{response.status}\n")
    return if response.success?

    debug("Body:\n#{response.body}\n")
    @success = false
    @full_error_messages << "#{resource} Endpoint raised error [HTTP status #{response.status}]"
  end

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end
end
