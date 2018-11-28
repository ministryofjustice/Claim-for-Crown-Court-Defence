RSpec::Matchers.define :have_link_to do |expected = nil|
  match do |actual|
    actual =~ /#{expected}/
  end

  failure_message do |actual|
    "expected #{actual.inspect} to include a url of #{expected.inspect}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.inspect} not to include a url of #{expected}"
  end
end
