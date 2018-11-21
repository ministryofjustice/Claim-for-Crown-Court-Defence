# Service to retrieve the unit price for a given fee.
# Unit price will require input from different attributes
# on the claim and may require the quantity from separate
# but related fees (i.e. for uplifts).
#
# Use this service for prices that can be determined
# with the supply of a value for only ONE unit type.
# This includes fixed fees and miscellaneous fees across
# LGFS and AGFS fee schemes.
#
module Claims
  module FeeCalculator
    class UnitPrice < CalculatePrice
      private

      def unit_price(modifier = nil)
        @modifier = modifier
        @prices = fee_scheme.prices(
          scenario: scenario.id,
          offence_class: offence_class_or_default,
          advocate_type: advocate_type,
          fee_type_code: fee_type_code_for(fee_type),
          limit_from: limit_from_default
        )
        price
      end

      def price
        raise 'Too many prices' if @prices.size > 1
        Price.new(@prices.first, @modifier, quantity_from_parent_or_one)
      end

      def uplift?
        fee_type.case_uplift? || fee_type.defendant_uplift?
      end

      def parent_fee_type
        return unless uplift?
        fee_type.case_uplift? ? case_uplift_parent : defendant_uplift_parent
      end

      def quantity_from_parent_or_one
        parent = parent_fee_type
        return 1 unless parent
        current_total_quantity_for_fee_type(parent)
      end

      def amount
        if fee_type.case_uplift?
          unit_price(:number_of_cases)
        elsif fee_type.defendant_uplift?
          unit_price(:number_of_defendants)
        else
          unit_price
        end
      end
    end
  end
end
