Remote::HttpClient.configure do |client|
  client.base_url = Settings.remote_api_url
  client.api_key = Settings.remote_api_key
  client.logger = Rails.logger
  client.open_timeout = 5
  client.read_timeout = 15
end
