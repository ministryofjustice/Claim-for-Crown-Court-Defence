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
    UnitModifier = Struct.new(:name, :limit_from, keyword_init: true)

    class UnitPrice < CalculatePrice
      private

      # TODO: retrial basic (basic) fee excluded where retrial starts before trial ends
      # - validation in place to prevent this now
      #
      # TODO: cracked before retrial basic (basic) fee excluded until
      #  - we expose retrial_reduction on these case types
      #  - we find out how to determine retrial interval.
      #    - expose `trial_concluded_at`?
      #    - months between `trial_concluded_at` and `cracked_at`
      #  - we confirm how to handle situations where retrial started before tria concluded
      #
      def exclusions
        raise Exceptions::RetrialReductionExclusion if uncalculatable_retrial_reduction_required?
        raise Exceptions::CrackedBeforeRetrialExclusion if cracked_before_retrial_interval_required?
      end

      def amount
        unit_price
      end

      def price_options
        opts = {}
        opts[:scenario] = scenario.id
        opts[:offence_class] = offence_class_or_default
        opts[:advocate_type] = advocate_type
        opts[:fee_type_code] = fee_type_code_for(fee_type)
        opts[:limit_from] = limit_from
        opts[:limit_to] = limit_to
        opts[:unit] = unit
        opts.compact_blank!
      end

      def unit_price
        @prices = fee_scheme.prices(**price_options)
        filter_third_cracked_prices
        price
      end

      # NOTE: needed because scheme 9, guilty pleas have a DAY unit price and a PPE unit price
      def unit
        basic_fee_uplift? ? 'DAY' : nil
      end

      def price
        raise Exceptions::PriceNotFound if @prices.empty?
        raise Exceptions::TooManyPrices if @prices.size > 1
        Price.new(@prices.first, modifiers, quantity_from_parent_or_one)
      end

      def basic_fee_uplift?
        %w[BANDR BANOC].include?(fee_type.unique_code)
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

      # TODO: refactor share retrial methods with grad price
      def retrial_interval_required?
        [
          agfs?,
          case_type&.fee_type_code.eql?('GRRTR'),
          fee_type_code_for(fee_type).eql?('AGFS_FEE'),
          retrial_reduction
        ].all?
      end

      def third_cracked_required?
        [
          agfs?,
          %w[GRRAK GRCBR].include?(case_type&.fee_type_code),
          basic_fee_uplift?
        ].all?
      end

      def filter_third_cracked_prices
        return unless third_cracked_required?
        @prices.keep_if do |price|
          price.modifiers.any? do |m|
            m.modifier_type.name.eql?('THIRD_CRACKED') && third_cracked.in?(m.limit_from..m.limit_to)
          end
        end
      end

      def unit_modifier(name, limit_from)
        UnitModifier.new(name:, limit_from:)
      end

      def modifiers
        @modifiers ||= [].tap do |arr|
          arr.append(unit_modifier(:retrial_interval, retrial_interval)) if retrial_interval_required?
          arr.append(unit_modifier(:number_of_cases, 2)) if fee_type.case_uplift?
          arr.append(unit_modifier(:number_of_defendants, 2)) if fee_type.defendant_uplift?
        end
      end
    end
  end
end
