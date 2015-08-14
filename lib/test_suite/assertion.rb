module TestSuite
  class Assertion
    attr_reader :errors

    def initialize(expectation)
      @func   = expectation.function
      @result = expectation.result
      @errors = []
    end

    def valid?
      candidate = @func.call

      if candidate == @result || candidate =~ @result
        true
      else
        log_error(candidate)
        false
      end
    end

    private

    def log_error(candidate)
      @errors << "Expected: #{@result}\nGot: #{candidate}"
    end
  end
end