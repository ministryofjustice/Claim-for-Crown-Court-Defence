RSpec::Matchers.define(:be_one_of) do |expected|
  match do |actual|
    expected.include?(actual)
  end

  failure_message do |actual|
    "expected one of #{expected}, got #{actual}"
  end

  failure_message_when_negated do |actual|
    "expected not to be one of #{expected}, got #{actual}"
  end
end
