# To run development against a local or other fee calculator
# client define LAA_FEE_CALCULATOR_HOST in your environment
# Not having an LAA_FEE_CALCULATOR_HOST envvar will result in use of the
# clients default host, which is currently the dev version of the API.
LAA::FeeCalculator.configure do |config|
  config.host = ENV['LAA_FEE_CALCULATOR_HOST'] if ENV['LAA_FEE_CALCULATOR_HOST']
end
