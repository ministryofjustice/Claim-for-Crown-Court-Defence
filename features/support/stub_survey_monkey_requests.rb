require 'webmock/cucumber'

Before('@stub_survey_monkey_success') do
  stub_request(:post, %r{\Ahttps://api.eu.surveymonkey.com/v3/.*} )
    .and_return(status: 201, body: { id: '123' }.to_json)
end

Before('@stub_survey_monkey_failure') do
  stub_request(:post, %r{\Ahttps://api.eu.surveymonkey.com/v3/.*} )
    .and_return(status: 500, body: { error: { id: '1050' } }.to_json)
end
