# Service to retrieve a bill scenario code
# that can be used to find the scenario id
# from the laa-fee-calculator API
#
module Claims
  module FeeCalculator
    class BillScenario
      delegate  :lgfs?,
                :interim?,
                :transfer?,
                :transfer_detail,
                :final?,
                :case_type,
                to: :claim

      attr_reader :claim, :fee_type, :namespace

      def initialize(claim, fee_type)
        @claim = claim
        @namespace = lgfs? ? 'CCLF' : 'CCR'
        @fee_type = fee_type
      end

      def call
        bill_scenario
      end

      private

      def bill_scenario
        return transfer_detail.bill_scenario if transfer?
        return find_by_code(fee_type.unique_code) if interim?
        find_by_code(case_type.fee_type_code)
      end

      def find_by_code(code)
        "#{namespace}::CaseTypeAdapter::BILL_SCENARIOS".constantize[code.to_sym]
      end
    end
  end
end
