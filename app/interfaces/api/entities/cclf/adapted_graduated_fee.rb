module API
  module Entities
    module CCLF
      class AdaptedGraduatedFee < AdaptedBaseBill
        expose :bill_scenario
        expose :quantity, format_with: :string
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :bill_scenario, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::GraduatedFeeAdapter.new(object)
        end
      end
    end
  end
end
