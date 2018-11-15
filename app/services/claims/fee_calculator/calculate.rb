# Service to calculate the total "price/bill" for a given fee.
# Note that this price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    Response = Struct.new(:success?, :data, :errors, :message, keyword_init: true)
    Data = Struct.new(:amount, :unit, keyword_init: true)

    class Calculate
      delegate  :earliest_representation_order_date,
                :agfs?,
                :lgfs?,
                :agfs_reform?,
                :case_type,
                :offence,
                to: :claim

      attr_reader :claim,
                  :options,
                  :fee_type,
                  :advocate_category,
                  :quantity,
                  :current_page_fees

      def initialize(claim, options)
        @claim = claim
        @options = options
      end

      def call
        setup(options)
        response(true, build_data(amount))
      rescue StandardError => err
        Rails.logger.error("error: #{err.message}")
        response(false, err, I18n.t('fee_calculator.calculate.amount_unavailable'))
      end

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options[:advocate_category] || claim.advocate_category
        @quantity = options[:quantity] || 1
        @current_page_fees = options[:fees].values
      rescue StandardError
        raise 'incomplete'
      end

      def amount
        raise 'implement in subclass'
      end

      def scheme_type
        agfs? ? 'AGFS' : 'LGFS'
      end

      def fee_scheme
        @fee_scheme ||= client.fee_schemes(type: scheme_type, case_date: earliest_representation_order_date.to_s(:db))
      end

      def bill_scenario
        return CCLF::CaseTypeAdapter::BILL_SCENARIOS[case_type.fee_type_code.to_sym] if lgfs?
        CCR::CaseTypeAdapter::BILL_SCENARIOS[case_type.fee_type_code.to_sym]
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

      # TODO: limit_from represents the price based on the quantity "instance"
      # e.g. AGFS scheme 10, Contempt scenario, Standard appearance fee
      #      attracts one price per unit/day (180 for a QC) for the first 6 days
      #      then 0.00 price for days 7 onwards. This breaks the "rate" per unit logic
      #      of CCCD and would need to be accounted for via the quantity * rate calculation
      #      instead, as one solution.
      # NOTE: In the API AGFS fee scheme prices have a limit_from minimum of 1, while
      # LGFS does not use this attribute and uses 0. github issue TODO?
      def limit_from_default
        agfs? ? 1 : 0
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
        ids = current_page_fees.map { |pf| pf[:fee_type_id] }
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
        fee_type.defendant_uplift_parent
      end

      def response(success, data, message = nil)
        return Response.new(success?: true, data: data, errors: nil, message: message) if success
        Response.new(success?: false, data: nil, errors: [data], message: message)
      end

      def build_data(data)
        return Data.new(amount: data.per_unit, unit: data.unit) if data.is_a?(Price)
        Data.new(amount: data)
      end

      def client
        @client ||= LAA::FeeCalculator.client
      end
    end
  end
end
