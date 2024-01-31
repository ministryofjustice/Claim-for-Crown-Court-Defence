# open_timeout value temporarily increased
# to reduce caseworkers timeout errors
#
# Ticket CFP-587 has been created to further investigate
# the root cause and therefore reduce the open_timeout
#
Rails.application.reloader.to_prepare do
  Remote::HttpClient.configure do |client|
    client.base_url = Settings.remote_api_url
    client.api_key = Settings.remote_api_key
    client.logger = Rails.logger
    client.open_timeout = 10
    client.timeout = 15
  end
end
