# Use this service for prices that are determined
# with the supply of multiple unit values.
#
# This includes LGFS (and AGFS?? TODO) graduated fees
#
module Claims
  module FeeCalculator
    class GraduatedPrice < CalculatePrice
      attr_reader :ppe, :days

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options[:advocate_category] || claim.advocate_category
        @days = options[:days] || 0
        @ppe = options[:ppe] || 0
        exclude_invalid_fee_calc
      rescue StandardError
        raise 'incomplete'
      end

      def exclude_invalid_fee_calc
        return unless %w[INRST INTDT INWAR].include?(fee_type.unique_code)
        raise StandardError, 'temporary exclusion of interim fee calc for trial start, retrial start and warrant types'
      end

      def amount
        fee_scheme.calculate do |options|
          options[:scenario] = scenario.id
          options[:offence_class] = offence_class_or_default
          options[:advocate_type] = advocate_type
          options[:fee_type_code] = fee_type_code_for(fee_type)

          options[:day] = days.to_i
          options[:ppe] = ppe.to_i

          # TODO: retrospectively use actual number of defendants
          # for LGFS transfer and graduated fee calc and remove
          # defendant uplift misc fee
          options[:number_of_defendants] = defendants.size if interim?
        end
      end
    end
  end
end
