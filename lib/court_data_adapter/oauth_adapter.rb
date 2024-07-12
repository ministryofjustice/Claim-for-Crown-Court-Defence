require 'court_data_adapter/oauth_adapter/response'

module CourtDataAdapter
  class OauthAdapter
    def initialize(*args); end

    def run(request_method, path, params: nil, headers: {}, body: nil)
      Response.new(access.request(request_method, "api/internal/v1/#{path}", params:, headers:, body:))
    end

    def use(*args); end

    private

    def access = @access ||= client.client_credentials.get_token

    def client
      @client ||= OAuth2::Client.new(
        ENV.fetch('COURT_DATA_ADAPTOR_API_UID', nil),
        ENV.fetch('COURT_DATA_ADAPTOR_API_SECRET', nil),
        site: ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil)
      )
    end
  end
end
