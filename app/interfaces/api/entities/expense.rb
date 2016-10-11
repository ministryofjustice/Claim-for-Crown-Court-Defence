module API
  module Entities
    class Expense < BaseEntity
      expose :date
      expose :type
      expose :location
      expose :mileage_rate
      expose :displayable_reason_text, as: :reason

      with_options(format_with: :decimal) do
        expose :distance
        expose :hours
        expose :quantity
        expose :rate
        expose :amount, as: :net_amount
        expose :vat_amount
      end

      private

      def type
        object.expense_type&.name
      end

      def mileage_rate
        object.mileage_rate&.name
      end
    end
  end
end
