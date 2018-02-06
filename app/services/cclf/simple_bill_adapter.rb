require_relative 'simple_bill_typeable'

module CCLF
  class SimpleBillAdapter < SimpleDelegator
    include SimpleBillTypeable

    def bill_scenario
      case_type_adapter.bill_scenario
    end

    private

    def case_type_adapter
      @adapter ||= ::CCLF::CaseTypeAdapter.new(claim.case_type)
    end
  end
end
