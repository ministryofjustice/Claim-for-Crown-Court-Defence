# mixin to share defendant uplift validation logic and
# methods between final and supplementary advocate
# claims
#
module Claim
  module DefendantUpliftValidations
    extend ActiveSupport::Concern

    included do
      private

      def validate_defendant_uplifts_basic_fees
        return unless [
          !@record.from_api?,
          !@record.fixed_fee_case?,
          defendant_uplifts_greater_than?(defendant_uplifts_basic_fees_counts, number_of_defendants)
        ].all?
        add_error(:base, 'defendant_uplifts_basic_fees_mismatch')
      end

      def fixed_fee_defendant_uplift_quantity_attribute
        position = @record.fixed_fees.find_index(&:defendant_uplift?) + 1
        "fixed_fee_#{position}_quantity"
      end

      def validate_defendant_uplifts_fixed_fees
        return unless [
          !@record.from_api?,
          @record.fixed_fee_case?,
          defendant_uplifts_greater_than?(defendant_uplifts_fixed_fees_counts, number_of_defendants)
        ].all?
        add_error(fixed_fee_defendant_uplift_quantity_attribute, 'defendant_uplifts_fixed_fees_mismatch')
      end

      def validate_defendant_uplifts_misc_fees
        return if @record.from_api?
        return unless defendant_uplifts_greater_than?(defendant_uplifts_misc_fees_counts, number_of_defendants)
        add_error(:base, 'defendant_uplifts_misc_fees_mismatch')
      end

      def number_of_defendants
        @record.defendants.count { |defendant| !defendant.marked_for_destruction? }
      end

      # we add one because uplift quantities reflect the number of "additional" defendants
      def defendant_uplifts_greater_than?(defendant_uplifts_counts, no_of_defendants)
        defendant_uplifts_counts.map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
      end

      def defendant_uplifts_basic_fees
        defendant_uplifts_fees(@record.basic_fees)
      end

      def defendant_uplifts_fixed_fees
        defendant_uplifts_fees(@record.fixed_fees)
      end

      def defendant_uplifts_misc_fees
        defendant_uplifts_fees(@record.misc_fees)
      end

      def defendant_uplifts_fees(fees)
        fees.select do |fee|
          !fee.marked_for_destruction? &&
            fee&.defendant_uplift?
        end
      end

      def defendant_uplifts_basic_fees_counts
        defendant_uplifts_counts_for(defendant_uplifts_basic_fees)
      end

      def defendant_uplifts_fixed_fees_counts
        defendant_uplifts_counts_for(defendant_uplifts_fixed_fees)
      end

      def defendant_uplifts_misc_fees_counts
        defendant_uplifts_counts_for(defendant_uplifts_misc_fees)
      end

      def defendant_uplifts_counts_for(defendant_uplifts)
        defendant_uplifts.each_with_object({}) do |fee, res|
          next if fee.quantity.blank?
          res[fee.fee_type.unique_code] ||= []
          res[fee.fee_type.unique_code] << fee.quantity
        end.values.map(&:sum)
      end
    end
  end
end
