class MaatService
  class Connection
    include Singleton

    def fetch(maat_reference)
      JSON.parse(client.get("assessment/rep-orders/#{maat_reference}").body)
    rescue Faraday::ConnectionFailed
      {}
    end

    private

    def client
      @client ||= Faraday.new(Settings.maat_api_url, request: { timeout: 2 }) do |conn|
        conn.headers['Authorization'] = "Bearer #{oauth_token}"
      end
    end

    def oauth_token
      response = Faraday.post(Settings.maat_api_oauth_url, request_params, request_headers)
      JSON.parse(response.body)['access_token']
    end

    def request_params
      {
        client_id: Settings.maat_api_oauth_client_id,
        client_secret: Settings.maat_api_oauth_client_secret,
        scope: Settings.maat_api_oauth_scope,
        grant_type: 'client_credentials'
      }
    end

    def request_headers
      { content_type: 'application/x-www-form-urlencoded' }
    end
  end
end
