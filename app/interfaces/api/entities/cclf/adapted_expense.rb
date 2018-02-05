module API
  module Entities
    module CCLF
      class AdaptedExpense < AdaptedBaseBill
        expose :bill_scenario

        expose :amount, format_with: :string
        expose :vat_amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :bill_scenario, to: :adapter

        def adapter
          @adapter ||= ::CCLF::ExpenseAdapter.new(object)
        end
      end
    end
  end
end
