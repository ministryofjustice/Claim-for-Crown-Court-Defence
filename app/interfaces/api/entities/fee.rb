module API
  module Entities
    class Fee < BaseEntity
      expose :type
      expose :code
      expose :date, format_with: :utc
      expose :case_numbers, if: lambda { |instance, _opts| instance.case_numbers.present? }

      with_options(format_with: :decimal) do
        expose :quantity
        expose :amount
        expose :rate
      end

      expose :warrant_issued_date, :warrant_executed_date, format_with: :utc,
             if: lambda { |instance, _opts| instance.is_warrant? }

      expose :sub_type, :sub_type_code, if: lambda { |instance, _opts| instance.sub_type.present? }

      private

      def type
        object.fee_type&.description
      end

      def code
        object.fee_type&.code
      end

      def sub_type
        object.sub_type&.description
      end

      def sub_type_code
        object.sub_type&.code
      end
    end
  end
end
