# Use this service for prices that are determined
# with the supply of multiple unit values.
#
# This includes LGFS (and AGFS?? TODO) graduated fees
#
module Claims
  module FeeCalculator
    class GraduatedPrice < CalculatePrice
      attr_reader :ppe, :pw, :days, :pages_of_prosecuting_evidence

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options.fetch(:advocate_category, advocate_category)
        @pages_of_prosecuting_evidence = options.fetch(:pages_of_prosecuting_evidence, prosecution_evidence)
        @days = options.fetch(:days, 0)
        @ppe = options.fetch(:ppe, 0)
        @pw = options.fetch(:pw, 0)
        exclusions
      rescue StandardError
        raise 'insufficient_data'
      end

      def prosecution_evidence
        prosecution_evidence?.to_i
      end

      # TODO: warrant fees to be excluded until
      # - fee calculator amended to have codes for warrant fee scenarios
      # - CCCD is able to apply the sub category of warrant fee scenario logic
      #
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
        raise Exceptions::InterimWarrantExclusion if fee_type.unique_code.eql?('INWAR')
        raise Exceptions::RetrialReductionExclusion if uncalculatable_retrial_reduction_required?
        raise Exceptions::CrackedBeforeRetrialExclusion if cracked_before_retrial_interval_required?
      end

      def amount
        fee_scheme.calculate(**calculator_options)
      end

      def calculator_options
        opts = {}
        opts[:scenario] = scenario.id
        opts[:offence_class] = offence_class_or_default
        opts[:advocate_type] = advocate_type
        opts[:pages_of_prosecuting_evidence] = pages_of_prosecuting_evidence
        opts[:fee_type_code] = fee_type_code_for(fee_type)
        opts[:day] = days.to_i
        opts[:ppe] = ppe.to_i if ppe.to_i.nonzero?
        opts[:pw] = pw.to_i if pw.to_i.nonzero?
        opts[:trial_length] = trial_length
        opts[:number_of_defendants] = number_of_defendants
        opts[:retrial_interval] = retrial_interval
        opts[:third_cracked] = third_cracked
        opts.compact_blank!
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

      def retrial_interval
        super if retrial_interval_required?
      end

      def retrial_interval_required?
        [
          agfs?,
          case_type&.fee_type_code.eql?('GRRTR'),
          retrial_reduction
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
