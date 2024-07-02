class MaatService
  class Connection
    include Singleton

    def fetch(maat_reference)
      JSON.parse(access.get("assessment/rep-orders/#{maat_reference}").body)
    rescue OAuth2::Error
      {}
    end

    private

    def access = @access ||= client.client_credentials.get_token

    def client
      @client ||= OAuth2::Client.new(
        Settings.maat_api_oauth_client_id,
        Settings.maat_api_oauth_client_secret,
        site: Settings.maat_api_url,
        token_url: Settings.maat_api_oauth_url
      )
    end
  end
end
