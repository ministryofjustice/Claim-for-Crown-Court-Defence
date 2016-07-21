#!/usr/bin/env ruby

require 'net/https'
require 'uri'

ENVIRONMENTS = {
    'dev' => 'dev-adp.dsd.io',
    'demo' => 'demo-adp.dsd.io',
    'sandbox' => 'api-sandbox-adp.dsd.io',
    'staging' => 'staging-adp.dsd.io',
    'gamma' => 'claim-crown-court-defence.service.gov.uk'
}

def hostname
  @hostname ||= (ENVIRONMENTS[ARGV[0]] || (raise 'Please specify the environment (%s) as the first argument' % ENVIRONMENTS.keys.join(',')))
end

def uri
  @uri ||= URI.parse("https://#{hostname}/ping.json")
end

def output(msg)
  puts '(%s) %s' % [Time.now.strftime('%H:%M:%S'), msg]
end

begin
  puts
  puts 'Checking %s | Ctrl+C to stop and exit' % uri
  puts

  status, timestamp = 200, Time.now

  while true do
    response = Net::HTTP.get_response(uri)
    res_code = response.code.to_i

    if status != res_code
      output 'Time elapsed since last status change: %s secs.' % (Time.now - timestamp).round(3)
      status, timestamp = res_code, Time.now
    end

    output "Response code: #{res_code}"

    sleep(1)
  end
rescue => e
  puts 'Usage: ./downtime environment'
  puts e
end
