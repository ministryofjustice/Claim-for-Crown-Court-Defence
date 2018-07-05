require 'laa/fee_calculator'

LAA::FeeCalculator::API.configure do |config|
  config.host = 'https://laa-fee-calculator-dev.apps.non-production.k8s.integration.dsd.io'
end
