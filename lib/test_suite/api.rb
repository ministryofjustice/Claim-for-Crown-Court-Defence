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
      [
        # fees
        Assertion.new(
          lambda { ApiClient::Create.fees({
            claim_id:    Claim.first.uuid,
            fee_type_id: FeeType.first.id,
            quantity:    1,
            amount:      1,
          })['id']}, 
          /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/
        ),
        # Add here
      ] + 

      # ApiClient::Validate methods 
      [
        # fees
        Assertion.new(
          lambda { ApiClient::Validate.fees({
            claim_id:    Claim.first.uuid,
            fee_type_id: FeeType.first.id,
            quantity:    1,
            amount:      1,
          })}, 
          { 'valid' => true }
        ),
        # Add here
      ] 
    end
  end
end