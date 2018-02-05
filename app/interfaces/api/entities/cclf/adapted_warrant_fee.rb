module API
  module Entities
    module CCLF
      class AdaptedWarrantFee < AdaptedBaseBill
        expose :bill_scenario
        expose :warrant_issued_date, :warrant_executed_date, format_with: :utc
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :bill_scenario, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::WarrantFeeAdapter.new(object)
        end
      end
    end
  end
end
