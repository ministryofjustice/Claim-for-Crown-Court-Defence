class Remotes::RemoteObject

  def self.api_get(endpoint)
    JSON.parse(RestClient.get("#{Settings.remote_api_url}#{endpoint}?api_key=#{Settings.remote_api_key}"))
  end

end
