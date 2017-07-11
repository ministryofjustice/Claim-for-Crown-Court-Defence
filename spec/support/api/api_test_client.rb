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
require 'caching/api_request'
require 'rest-client'
Dir[File.join(Rails.root, 'spec', 'support', 'api', 'claims', '*.rb')].each { |file| require file }

class ApiTestClient
  attr_reader :success, :full_error_messages, :messages

  EXTERNAL_USER_PREFIX = 'api/external_users'.freeze

  def initialize
    @full_error_messages = []
    @messages = []
    @success = true
  end

  def run
    AdvocateClaimTest.new(client: self).test_creation!
    FinalClaimTest.new(client: self).test_creation!
    InterimClaimTest.new(client: self).test_creation!
    TransferClaimTest.new(client: self).test_creation!
  end

  def run_debug_session
    DebugFinalClaimTest.new(client: self).test_creation!
  end

  def failure
    !@success
  end

  def post_to_endpoint(resource, payload, debug = false)
    endpoint = RestClient::Resource.new([api_root_url, EXTERNAL_USER_PREFIX, resource].join('/'))
    if debug
      puts ">>> POSTING TO #{endpoint} <<<<<"
      puts payload
    end
    endpoint.post(payload, content_type: :json, accept: :json) do |response, _request, _result|
      if debug
        puts "<<< RESPONSE #{response.code} <<<<<"
        puts "<<< #{response.body} "
        puts " \n"
      end
      handle_response(response, resource)
      response
    end
  end

  def post_to_endpoint_with_debug(resource, payload)
    post_to_endpoint(resource, payload, true)
  end

  #
  # don't raise exceptions but, instead, return the
  # response for analysis.
  #
  def get_dropdown_endpoint(resource, api_key, params = {})
    query_params = '?' + params.merge(api_key: api_key).to_query
    endpoint = RestClient::Resource.new([api_root_url, 'api', resource].join('/') + query_params)

    Caching::ApiRequest.cache(endpoint.url) do
      endpoint.get do |response, _request, _result|
        handle_response(response, resource)
        response
      end
    end
  end

  private

  def handle_response(response, resource)
    return if response.code.to_s =~ /^2/
    @success = false
    @full_error_messages << "#{resource} Endpoint raised error - #{response}"
  end

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end
end
