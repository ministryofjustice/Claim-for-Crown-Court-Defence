# RSpec matcher for validates_with.
# Usage:
#
#  describe User do
#    it { is_expected.to validate_with CustomValidator }
#  end

RSpec::Matchers.define :validate_with do |validator|
  match do |subject|
    subject.class.validators.map(&:class).include? validator
  end

  description do
    "validate with #{validator}"
  end

  failure_message do
    "expected to validate with #{validator}"
  end

  failure_message_when_negated do
    "expected not to validate with #{validator}"
  end
end
