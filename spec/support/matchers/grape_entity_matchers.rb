require 'rspec/expectations'

RSpec::Matchers.define :expose do |expected|
  match do |actual|
    @hashed = parse(actual)
    @hashed.key?(expected)
  end

  def parse(actual)
    JSON.parse(actual, symbolize_names: true).with_indifferent_access
  rescue JSON::ParserError, TypeError
    JSON.parse(actual.to_json, symbolize_names: true).with_indifferent_access
  end

  description do
    "expose the \"#{expected}\" attribute"
  end

  failure_message do |_actual|
    "expected JSON attributes #{@hashed.keys} to include \"#{expected}\""
  end

  failure_message do |_actual|
    "expected JSON attributes #{@hashed.keys} to include \"#{expected}\""
  end

  failure_message_when_negated do |_actual|
    "expected JSON attributes #{@hashed.keys} not to include #{expected} "
  end
end
