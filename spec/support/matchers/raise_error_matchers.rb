require 'rspec/expectations'

RSpec::Matchers.define :raise_only_amount_assessed_error do
  match do |actual|
    begin
      actual.call
      false
    rescue StateMachines::InvalidTransition => err
      @error_message = err.message
      err.message.match?(/\(Reason\(s\)\: Amount assessed Amount assessed cannot be zero for claims in state .*\)/)
    end
  end

  def supports_block_expectations?
    true
  end

  failure_message do |actual|
    "expected calling state transition to only raise an amount assessed error but got #{@error_message.nil? ? 'no error!' : "\"#{@error_message}\""}"
  end

  failure_message_when_negated do |actual|
    "expected calling state transition to only raise an amount assessed error but got #{@error_message.nil? ? 'no error!' : "\"#{@error_message}\""}"
  end
end
