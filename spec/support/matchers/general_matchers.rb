require 'rspec/expectations'

RSpec::Matchers.define :have_constant do |expected|
  expected.assert_valid_keys :name, :value
  match do |owner|
    result = owner.const_defined?(expected[:name])
    result = owner.const_get(expected[:name]) == expected[:value] if expected.key? :value
    result
  end

  description do
    msg = "have a constant named #{expected[:name]}"
    msg += " with a value of #{expected[:value]}." if expected.key? :value
    msg
  end

  failure_message do |owner|
    msg = "expected #{owner} to have a constant named #{expected[:name]} defined"
    msg += " with a value of #{expected[:value]}." if expected.key? :value
    msg
  end

  failure_message_when_negated do |owner|
    msg = "expected #{owner} not to have a constant named #{expected[:name]} defined"
    msg += " with a value of #{expected[:value]}." if expected.key? :value
    msg
  end
end
