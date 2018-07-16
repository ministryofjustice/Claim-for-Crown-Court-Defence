# Service to calculate the unit price for a given fee.
# Unit price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    # TODO: this is using:
    # 1. for primary/main fixed fees it use the calculate endpoint with quantity/days of 1 and no modifiers
    # 2. for case uplifts it calculates for the matching "primary" fee type with number of cases
    #    modifier of 2 (1 additional case) and "days/quantity" taken from the primary fee types' quantity.
    # However, could use the prices endpoint of API directly or request a new endpoint to reduce number
    # of calls and/or simplify.
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

          # TODO: this will need to be dynamically determined eventually
          # e.g.
          #   units = fee_scheme.units(options).map { |u| u.id.downcase }
          #   units.each { |unit| options[unit.to_sym] = unit_from_parent_or_one }
          options[:day] = unit_from_parent_or_one
        end
      end

      def unit_from_parent_or_one
        return 1 unless fee_type.case_uplift?

        parent_fee_type = case_uplift_parent
        days = current_page_fees.inject(0) do |sum, fee|
          fee[:fee_type_id].eql?(parent_fee_type.id.to_s) ? sum + fee[:quantity].to_i : sum
        end
        days || 1
      end

      def case_uplift_unit_price
        unit_price(:number_of_cases) - unit_price
      end
    end
  end
end
