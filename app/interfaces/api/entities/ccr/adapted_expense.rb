module API
  module Entities
    module CCR
      class AdaptedExpense < API::Entities::BaseEntity
        with_options(format_with: :string) do
          expose :bill_type
          expose :bill_subtype
          expose :date_incurred, format_with: :utc
          expose :description
          expose :quantity
          expose :rate
        end

        private

        delegate :bill_type, :bill_subtype, :description, :quantity, :rate, to: :adapter

        def adapter
          @adapter ||= ::CCR::ExpensesAdapter.new(object)
        end

        def date_incurred
          object.date
        end
      end
    end
  end
end
