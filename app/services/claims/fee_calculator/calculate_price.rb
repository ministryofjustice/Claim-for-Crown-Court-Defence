# Service to calculate the total "price/bill" for a given fee.
# Note that this price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    class CalculatePrice
      TRIAL_CRACKED_AT_THIRD_MAPPINGS = {
        first_third: 1,
        second_third: 2,
        final_third: 3
      }.with_indifferent_access.freeze

      delegate  :earliest_representation_order_date,
                :main_hearing_date,
                :advocate_category,
                :agfs?,
                :lgfs?,
                :interim?,
                :agfs_reform?,
                :trial_concluded_at,
                :retrial_reduction,
                :retrial_started_at,
                :trial_cracked_at_third,
                :case_type,
                :offence,
                :defendants,
                :prosecution_evidence?,
                to: :claim

      delegate :limit_from, to: :fee_type_limit
      delegate :limit_to, to: :fee_type_limit

      attr_reader :claim,
                  :options,
                  :fee_type,
                  :advocate_category,
                  :pages_of_prosecuting_evidence,
                  :quantity,
                  :current_page_fees

      def initialize(claim, options)
        @claim = claim
        @options = options
      end

      def call
        setup(options)
        Request.new(self).call
      rescue StandardError => e
        Rails.logger.error("error: #{e.message}")
        Response.new(success?: false,
                     data: nil,
                     errors: [e.message],
                     message: I18n.t('fee_calculator.calculate.amount_unavailable'))
      end

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options[:advocate_category] || claim.advocate_category
        @pages_of_prosecuting_evidence = options[:pages_of_prosecuting_evidence] || claim.prosecution_evidence
        @quantity = options[:quantity] || 1
        @current_page_fees = options[:fees].values
        @london_rates_apply = claim.london_rates_apply
        exclusions
      rescue StandardError
        raise Exceptions::InsufficientData
      end

      def exclusions
        raise 'implement in subclass'
      end

      def amount
        raise 'implement in subclass'
      end

      def scheme_type
        agfs? ? 'AGFS' : 'LGFS'
      end

      def fee_scheme
        @fee_scheme ||= client.fee_schemes(
          type: scheme_type,
          case_date: earliest_representation_order_date.to_fs(:db),
          main_hearing_date: main_hearing_date&.to_fs(:db)
        )
      end

      def bill_scenario
        BillScenario.new(claim, fee_type).call
      end

      # TODO: consider creating a mapping to fee calculator id's
      # - less "safe" but faster/negates the need to query the API??
      #
      def scenario
        fee_scheme.scenarios.find_by(code: bill_scenario)
      end

      # Send a default offence as fee calc currently requires offences
      # for some prices even though the values are identical for different
      # offence classes/bands.
      # TODO: fee calculator API should not require
      # offences for at least "Elected case not proceeded"
      #
      def offence_class_or_default
        if agfs_reform?
          offence&.offence_band&.description || '17.1'
        else
          offence&.offence_class&.class_letter || 'H'
        end
      end

      def advocate_type
        CCR::AdvocateCategoryAdapter.code_for(advocate_category) if advocate_category
      end

      # TODO: limits control the applicable price based on the quantity "instance"
      # e.g. AGFS scheme 10, Contempt scenario, Standard appearance fee
      #      attracts one price per unit/day (180 for a QC) for the first 6 days
      #      then 0.00 price for days 7 onwards. This breaks the "rate" per unit logic
      #      of CCCD and would need to be accounted for via the quantity * rate calculation
      #      instead, as one solution.
      # NOTE: In the API AGFS fee scheme prices have a limit_from minimum of 1, while
      # LGFS does not use this attribute and uses 0. github issue TODO?
      #
      def fee_type_limit
        @fee_type_limit ||= FeeTypeLimit.new(fee_type, claim)
      end

      def fee_type_mappings
        FeeTypeMappings.instance
      end

      def fee_type_code_for(fee_type)
        return 'LIT_FEE' if lgfs?
        fee_type = case_uplift_parent if fee_type.case_uplift?
        fee_type = defendant_uplift_parent if fee_type.defendant_uplift?
        fee_type_mappings.all[fee_type&.unique_code&.to_sym][:bill_subtype]
      end

      def current_fee_types
        return @current_fee_types if @current_fee_types
        ids = current_page_fees.pluck(:fee_type_id)
        @current_fee_types = Fee::BaseFeeType.where(id: ids)
      end

      def current_total_quantity_for_fee_type(fee_type)
        current_page_fees.inject(0) do |sum, fee|
          fee[:fee_type_id].to_s.eql?(fee_type.id.to_s) ? sum + fee[:quantity].to_i : sum
        end
      end

      def primary_fee_type_on_page
        primary_fee_types = current_fee_types.where(unique_code: fee_type_mappings.primary_fee_types.keys)
        return nil if primary_fee_types.size > 1
        primary_fee_types.first
      end

      def case_uplift_parent
        return primary_fee_type_on_page if fee_type.orphan_case_uplift?
        fee_type.case_uplift_parent
      end

      def defendant_uplift_parent
        return primary_fee_type_on_page if fee_type.orphan_defendant_uplift?
        fee_type.defendant_uplift_parent(claim)
      end

      # Remuneration regulations, Paragraph 2(3), Schedule 1
      # -1 (retrial start before trial ends) - this applies 0% reduction logic but is validated against
      # 0 (within 1 calendar month) requires a 30% reduction of equivalent trial fee
      # 1 (more than 1 calendar month) requires a 20% reduction of equivalent trial fee
      def retrial_interval
        return -1 if retrial_started_at < trial_concluded_at
        retrial_started_at.between?(trial_concluded_at, trial_concluded_at + 1.month) ? 0 : 1
      end

      def third_cracked
        TRIAL_CRACKED_AT_THIRD_MAPPINGS[trial_cracked_at_third]
      end

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

      def client
        @client ||= LAA::FeeCalculator.client
      end
    end
  end
end
