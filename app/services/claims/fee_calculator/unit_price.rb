# Service to calculate the unit price for a given fee.
# Unit price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    # TODO: this is simply using calculate endpoint with quantity of 1
    # to get the unit price, and number_of_cases modifier of two to get unit price for
    # case uplift types.
    # However, could use the prices endpoint directly
    # - amend laa-fee-calculator-client gem to add it.
    #
    class UnitPrice < Calculate
      def call
        setup(options)
        amount = fee_type.case_uplift? ? case_uplift_unit_price : unit_price
        response(true, amount)
      rescue StandardError => err
        Rails.logger.error(err.message)
        response(false, err, 'Price unavailable')
      end

      private

      def unit_price(modifier = nil)
        fee_scheme.calculate do |options|
          options[:scenario] = scenario.id
          options[:offence_class] = offence_class
          options[:advocate_type] = advocate_type
          options[:fee_type_code] = fee_type_code_for(fee_type)
          options[modifier] = 2 if modifier.present?

          units = fee_scheme.units(options).map { |u| u.id.downcase }
          units.each { |unit| options[unit.to_sym] = 1 }
        end
      end

      def case_uplift_unit_price
        unit_price(:number_of_cases) - unit_price
      end
    end
  end
end
