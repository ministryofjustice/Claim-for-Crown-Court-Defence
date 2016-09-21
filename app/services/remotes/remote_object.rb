
module Remotes

  class RemoteTimeoutError < StandardError; end

  class RemoteObject

    def self.api_get(endpoint)
      Timeout.timeout(2.5, RemoteTimeoutError) do
        JSON.parse(RestClient.get("#{Settings.remote_api_url}#{endpoint}?api_key=#{Settings.remote_api_key}"))
      end
    end

  end
end