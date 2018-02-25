require 'rspec/expectations'

RSpec::Matchers.define :contain_claims do |*expected|
  match do |actual|
    result = expected.size == actual.size
    expected.each do |e|
      unless actual.include?(e)
        result = false
        break
      end
    end
  end

  failure_message do |actual|
    "expected that records:\n\t #{actual.inspect} \n\nwould be equal to records\n\t #{expected.inspect}"
  end
end

RSpec::Matchers.define :be_within_seconds_of do |expected_date, leeway|
  match do |actual|
    upper_limit = actual + leeway.seconds
    lower_limit = actual - leeway.seconds
    expected_date > lower_limit && expected_date < upper_limit
  end
end
