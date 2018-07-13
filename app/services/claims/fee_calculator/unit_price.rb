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

        if fee_type.case_uplift?
          unit_price_for_modifier = unit_price(:number_of_cases)
          final_unit_price = unit_price_for_modifier - unit_price
        else
          final_unit_price = unit_price
        end

        response(true, final_unit_price)
      rescue StandardError => err
        response(false, err, 'Price unavailable')
      end

      def unit_price(modifier = nil)
        calc_options = {}
        calc_options[:scenario] = scenario.id
        calc_options[:offence_class] = offence_class
        calc_options[:advocate_type] = advocate_type
        calc_options[:fee_type_code] = fee_type_code_for_uplift(fee_type) if fee_type.case_uplift?
        calc_options[:fee_type_code] = fee_type_code_for(fee_type) unless fee_type.case_uplift?

        units = fee_scheme.units(calc_options).map { |u| u.id.downcase }
        units.each do |unit|
          calc_options[unit.to_sym] = 1
        end

        calc_options[modifier] = 2 if modifier.present?
        fee_scheme.calculate(calc_options)
      end

      def fee_type_code_for_uplift(fee_type)
        # TODO: hacky but there is no relationship between fixed fee "primary" types
        # and their case uplift equivalent.
        # - could create relationship on models/database
        #
        non_uplift_fee_type = Fee::BaseFeeType
                              .where('description = ?', fee_type.description.gsub(' uplift', ''))
                              .where.not('description ILIKE ?', '%uplift%')
                              .first
        fee_type_code_for(non_uplift_fee_type)
      end
    end
  end
end
