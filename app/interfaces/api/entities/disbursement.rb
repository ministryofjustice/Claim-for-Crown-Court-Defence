module API
  module Entities
    class Disbursement < BaseEntity
      expose :type

      with_options(format_with: :decimal) do
        expose :net_amount
        expose :vat_amount
        expose :total
      end

      private

      def type
        object.disbursement_type&.name
      end
    end
  end
end
