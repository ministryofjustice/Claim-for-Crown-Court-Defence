module API
  module Entities
    class BaseFeeType < BaseEntity
      expose :id
      expose :type
      expose :description
      expose :code
      expose :unique_code
      expose :max_amount
      expose :calculated
      expose :roles
      expose :quantity_is_decimal
      expose :case_numbers_required

      private

      def case_numbers_required
        object.case_uplift?
      end
    end
  end
end
