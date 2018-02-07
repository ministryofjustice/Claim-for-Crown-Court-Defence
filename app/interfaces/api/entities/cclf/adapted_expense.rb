module API
  module Entities
    module CCLF
      class AdaptedExpense < AdaptedBaseBill
        expose :total, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :total, :vat_included, to: :adapter

        def adapter
          @adapter ||= ::CCLF::ExpenseAdapter.new(object)
        end
      end
    end
  end
end
