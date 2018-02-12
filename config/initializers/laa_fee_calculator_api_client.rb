require 'laa/fee_calculator'

LAA::FeeCalculator::API.configure do |config|
  config.host = 'http://localhost:8000'
end
