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
        response(true, amount)
      rescue StandardError => err
        Rails.logger.error(err.message)
        response(false, err, I18n.t('fee_calculator.unit_price.amount_unavailable'))
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

      def uplift?
        fee_type.case_uplift? || fee_type.defendant_uplift?
      end

      def parent_fee_type
        return unless uplift?
        fee_type.case_uplift? ? case_uplift_parent : defendant_uplift_parent
      end

      def unit_from_parent_or_one
        parent = parent_fee_type
        return 1 unless parent
        current_total_quantity_for_fee_type(parent)
      end

      # TODO: promote?
      def current_total_quantity_for_fee_type(fee_type)
        current_page_fees.inject(0) do |sum, fee|
          fee[:fee_type_id].to_s.eql?(fee_type.id.to_s) ? sum + fee[:quantity].to_i : sum
        end
      end

      def uplift_unit_price(modifier)
        unit_price(modifier.to_sym) - unit_price
      end

      def defendant_uplift_unit_price
        unit_price(:number_of_defendants) - unit_price
      end

      def amount
        if fee_type.case_uplift?
          uplift_unit_price(:number_of_cases)
        elsif fee_type.defendant_uplift?
          # TODO: This call replaced uplift_unit_price(:number_of_defendants)
          # which seems to return the same value, so one or other should be used
          defendant_uplift_unit_price
        else
          unit_price
        end
      end
    end
  end
end
