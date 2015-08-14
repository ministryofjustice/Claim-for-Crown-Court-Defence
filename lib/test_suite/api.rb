require_relative 'assertion'
require_relative 'expectations'

module TestSuite 
  class Api < Base
    def initialize
      super(assertion_factory)
    end

    private

    def assertion_factory
      # ApiClient::Info methods
      ApiInfoExpectations.default.all.map { |func_name, expectation| 
        ApiInfoAssertion.new(func_name, expectation)
      } +
      
      # ApiClient::Create methods 
      ApiCreateExpectations.default.all.map { |func_name, expectation| 
        Assertion.new(func_name, expectation)
      } +

      # ApiClient::Validate methods 
       ApiValidateExpectations.default.all.map { |func_name, expectation| 
        Assertion.new(func_name, expectation)
      } 
    end
  end
end