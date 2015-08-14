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
      TestSuite::ApiInfoExpectations.default.all.map { |func_name, expectation| 
        TestSuite::ApiInfoAssertion.new(func_name, expectation)
      } +
      
      # ApiClient::Create methods 
      # Add here
      [] + 

      # ApiClient::Validate methods 
      # Add here
      []
    end
  end
end