require_relative 'assertion'

module TestSuite 
  class Api < Base
    def initialize
      super(assertion_factory)
    end

    private

    def assertion_factory
      
      # ApiClient::V1::Info methods
      info_expectations.map { |name, expectation| 
        TestSuite::ApiClientInfoAssertion.new(name, expectation)
      } +
      
      # ApiClient::V1::Create methods 
      [
      ] +
      
      # ApiClient::V1::Validate methods 
      [
      ]
    end

    def info_expectations
      {
        case_types:              Settings.case_types,
        courts:                  parse(Court.all),
        advocate_categories:     Settings.advocate_categories,
        prosecuting_authorities: Settings.prosecuting_authorities,
        trial_cracked_at_thirds: Settings.trial_cracked_at_third,
        granting_body_types:     Settings.court_types,
        offence_classes:         parse(OffenceClass.all),
        offences:                parse(Offence.all),
        fee_categories:          parse(FeeCategory.all),
        fee_types:               parse(FeeType.all),
        expense_types:           parse(ExpenseType.all)
      }
    end

    def parse(activerecord_collection)
      JSON.parse(MultiJson.dump(activerecord_collection))
    end
  end
end