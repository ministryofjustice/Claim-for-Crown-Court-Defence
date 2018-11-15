# Use this service for prices that are determined
# with the supply of multiple unit values.
#
# This includes LGFS (and AGFS?? TODO) gradauted fees
#
module Claims
  module FeeCalculator
    class GraduatedPrice < Calculate
      attr_reader :ppe, :days

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options[:advocate_category] || claim.advocate_category
        @days = options[:days] || 0
        @ppe = options[:ppe] || 0
      rescue StandardError
        raise 'incomplete'
      end

      def amount
        fee_scheme.calculate do |options|
          options[:scenario] = scenario.id
          options[:offence_class] = offence_class_or_default
          options[:advocate_type] = advocate_type
          options[:fee_type_code] = fee_type_code_for(fee_type)

          options[:day] = days.to_i
          options[:ppe] = ppe.to_i

          # In CCCD claiming for defendant uplift is handled as a misc fee.
          # Defendant uplifts need proper handling as part of the grad fee.
          # rely on fee calc default now (which assumes one)
          # options[:number_of_defendants] = 1
        end
      end
    end
  end
end
