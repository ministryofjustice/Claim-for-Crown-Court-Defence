# FIXME: testing fee calculator integration against local server
# not including this will mean you use the clients default host
# which is the dev version of the API.
LAA::FeeCalculator.configure do |config|
  config.host = 'http://localhost:8000/api/v1'
end
