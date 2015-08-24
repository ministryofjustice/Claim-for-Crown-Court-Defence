module TestSuite
  class Base
    attr_reader :errors

    def initialize(assertions)
      @assertions = assertions
      @errors     = []
    end

    def run
      success = @assertions.all?(&:valid?)
      @errors = @assertions.map { |a| a.errors }.flatten
      success
    end
  end
end