require 'webmock/cucumber'

Before('@stub_calculator_request_and_fail') do
  stub_request(:get, %r{\Ahttps://laa-fee-calculator.service(.*)/api/v1/.*\z}).
    to_return(status: 400, body: {'error': 'delete console.log from JS if this is in features'}.to_json, headers: {})
end
