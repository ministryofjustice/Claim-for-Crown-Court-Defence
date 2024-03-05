module CaseWorkers
  class RepresentationOrder < BasePresenter
    presents :representation_order
    def maat_details
      client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], site: ENV['OAUTH_SCOPE'])
      token  = client.password.get_token('username', 'password', { headers: { 'Authorization' => 'Basic my_api_key' } })

      conn = Faraday.new(url: ENV['OAUTH_URL']) do |builder|
        builder.request :oauth2_refresh, token
        builder.adapter Faraday.default_adapter
      end

      conn.get "/maat-cd-api/standard"
    end

    # def maat_details = @maat_details ||= MaatService.call(maat_reference:)
  end
end
