require 'rspec/expectations'

RSpec::Matchers.define :raise_only_amount_assessed_error do
  match do |actual|
    actual.call
    false
  rescue StateMachines::InvalidTransition => e
    @error_message = e.message
    e.message.match?(/\(Reason\(s\): Amount assessed Amount assessed cannot be zero for claims in state .*\)/)
  end

  def supports_block_expectations?
    true
  end

  failure_message do
    "expected calling state transition to only raise an amount assessed error but got #{@error_message.nil? ? 'no error!' : "\"#{@error_message}\""}"
  end

  failure_message_when_negated do
    "expected calling state transition to only raise an amount assessed error but got #{@error_message.nil? ? 'no error!' : "\"#{@error_message}\""}"
  end
end
