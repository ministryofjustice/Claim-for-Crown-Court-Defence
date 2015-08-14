module TestSuite
  class Assertion
    attr_reader :errors

    def initialize(func, expectation)
      @func        = func
      @expectation = expectation
      @errors      = []
    end

    def valid?
      result = @func.call

      if result == @expectation || result =~ @expectation
        true
      else
        log_error(result)
        false
      end
    end

    private

    def log_error(result)
      @errors << "Expected: #{@expectation}\nGot: #{result}"
    end
  end

  class ApiInfoAssertion < Assertion
    def initialize(name, expectation)
      super(lambda { ApiClient::Info.method(name).call }, expectation)
    end
  end
end