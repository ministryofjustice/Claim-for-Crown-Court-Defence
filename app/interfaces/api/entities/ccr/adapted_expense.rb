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

        def adapter
          @adapter ||= ::CCR::ExpensesAdapter.new(object)
        end

        def bill_type
          adapter.bill_type
        end

        def bill_subtype
          adapter.bill_sub_type
        end

        def date_incurred
          object.date
        end

        def description
          adapter.description
        end

        def quantity
          adapter.quantity
        end

        def rate
          adapter.rate
        end
      end
    end
  end
end
