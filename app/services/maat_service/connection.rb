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
      @client ||= Faraday.new(ENV.fetch('MAAT_API_DEV_URL'), request: { timeout: 2 }) do |conn|
        conn.headers['Authorization'] = "Bearer #{oauth_token}"
      end
    end

    def oauth_token
      response = Faraday.post(ENV.fetch('OAUTH_URL'), request_params, request_headers)
      JSON.parse(response.body)['access_token']
    end

    def request_params

      {
        client_id: ENV.fetch('OAUTH_CLIENT_ID'),
        client_secret: ENV.fetch('OAUTH_CLIENT_SECRET'),
        scope: ENV.fetch('OAUTH_SCOPE'),
        grant_type: 'client_credentials'
      }
    end

    def request_headers
      { content_type: 'application/x-www-form-urlencoded' }
    end
  end
end
