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
        exclusions
      rescue StandardError
        raise 'insufficient_data'
      end

      # TODO: warrant fees to be excluded until
      # - fee calculator amended to have codes for warrant fee scenarios
      # - CCCD is able to apply the sub category of warrant fee scenario logic
      #
      # TODO: retrial basic (basic) fee excluded where retrails starts before trial ends
      # - we confirm how to handle situations where retrial started before tria concluded
      #
      # TODO: cracked before retrial basic (basic) fee excluded until
      #  - we expose retrial_reduction on these case types
      #  - we find out how to determine retrial interval.
      #    - expose `trial_concluded_at`?
      #    - months between `trial_concluded_at` and `cracked_at`
      #  - we confirm how to handle situations where retrial started before tria concluded
      #
      def exclusions
        raise Exceptions::InterimWarrantExclusion if fee_type.unique_code.eql?('INWAR')
        raise Exceptions::RetrialReductionExclusion if uncalculatable_retrial_reduction_required?
        raise Exceptions::CrackedBeforeRetrialExclusion if cracked_before_retrial_interval_required?
      end

      def amount
        fee_scheme.calculate(calculator_options)
      end

      def calculator_options
        opts = {}
        opts[:scenario] = scenario.id
        opts[:offence_class] = offence_class_or_default
        opts[:advocate_type] = advocate_type
        opts[:fee_type_code] = fee_type_code_for(fee_type)
        opts[:day] = days.to_i
        opts[:ppe] = ppe.to_i
        opts[:trial_length] = trial_length
        opts[:number_of_defendants] = number_of_defendants
        opts[:retrial_interval] = retrial_interval
        opts[:third_cracked] = third_cracked
        opts.keep_if { |_k, v| v.present? }
      end

      def trial_length
        days.to_i if trial_length_required?
      end

      def trial_length_required?
        %w[INTDT INRST].include?(fee_type.unique_code)
      end

      def number_of_defendants
        defendants.size if lgfs?
      end

      # TODO: refactor share retrial methods with unit price
      def retrial_interval
        _retrial_interval if retrial_interval_required?
      end

      # TODO: refactor share retrial methods with grad price
      #
      # Remuneration regulations, Paragraph 2(3), Schedule 1
      # -1 (retrial start before trial ends) - this applies 0% reduction logic which is TBC
      # 0 (within 1 calendar month) requires a 30% reduction of equivalent trial fee
      # 1 (more than 1 calendar month) requires a 20% reduction of equivalent trial fee
      def _retrial_interval
        return -1 if retrial_started_at < trial_concluded_at
        retrial_started_at.between?(trial_concluded_at, trial_concluded_at + 1.month) ? 0 : 1
      end

      # TODO: refactor share retrial methods with grad price
      def retrial_interval_required?
        [
          agfs?,
          case_type&.fee_type_code.eql?('GRRTR'),
          retrial_reduction
        ].all?
      end

      # TODO: refactor share retrial methods with grad price
      def uncalculatable_retrial_reduction_required?
        retrial_interval_required? && retrial_started_at < trial_concluded_at
      end

      # TODO: need to expose `retrial_reduction` for claims of this case type and apply here
      def cracked_before_retrial_interval_required?
        [
          agfs?,
          case_type&.fee_type_code.eql?('GRCBR')
        ].all?
      end

      def third_cracked
        super if third_cracked_required?
      end

      def third_cracked_required?
        agfs? && %w[GRRAK GRCBR].include?(case_type&.fee_type_code)
      end
    end
  end
end
