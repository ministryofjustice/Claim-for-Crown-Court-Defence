require 'ostruct'

# Service to calculate the total "price/bill" for a given fee.
# Note that this price will require input from different attributes
# on the claim and may require input from different CCCD fees
# to be consolidated/munged.
#
module Claims
  module FeeCalculator
    Response = Struct.new(:success?, :data, :errors, :message, keyword_init: true)
    Data = Struct.new(:amount, keyword_init: true)

    class Calculate
      delegate  :earliest_representation_order_date,
                :agfs?,
                :case_type,
                :advocate_category,
                :offence,
                to: :@claim

      attr_reader :claim, :options, :fee_type, :advocate_category, :quantity, :current_page_fees

      def initialize(claim, options)
        @claim = claim
        @options = options
      end

      def call
        setup(options)

        amount = calculate
        response(true, amount)
      rescue StandardError => err
        Rails.logger.error(err.message)
        response(false, err, 'Price unavailable')
      end

      private

      def setup(options)
        @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
        @advocate_category = options[:advocate_category] || advocate_category
        @quantity = options[:quantity] || 1
        @current_page_fees = options[:fees].values
      end

      def calculate
        fee_scheme.calculate do |options|
          options[:scenario] = scenario.id
          options[:offence_class] = offence_class
          options[:advocate_type] = advocate_type
          options[:fee_type_code] = fee_type_code_for(fee_type)

          # units
          # TODO: which unit to use and their values need to be dynamically determined.
          # Current code only works assuming there is only one unit type and the quantity of
          # the fee is for that unit type.
          units = fee_scheme.units(options).map { |u| u.id.downcase }
          units.each do |unit|
            options[unit.to_sym] = quantity.to_f
          end

          # TODO: aberrations
          # - elected case not proceeded is a scenario type with ccr fee type code of AGFS_FEE
          # - cracked case discontinued - not sure we should even have this fixed fee in CCCD after speaking to BA??

          # modifiers
          # TODO: modifier needs to be dynamically determined and could be more than one
          # TODO: modifier values should be based on "munging" uplifts and "number of.." fee types
          # rather than actual number of defendants/cases (based on only paying what they ask for logic)
          # options[:number_of_defendants] = 1
          # options[:number_of_cases] = 1
        end
      end

      def scheme_type
        agfs? ? 'AGFS' : 'LGFS'
      end

      def fee_scheme
        @fee_scheme ||= client.fee_schemes(type: scheme_type, case_date: earliest_representation_order_date.to_s(:db))
      end

      def scenario
        # TODO: create select/find_by calls to list endpoints in client gem
        fee_scheme.scenarios.select do |s|
          s.code.eql?(CCR::CaseTypeAdapter::BILL_SCENARIOS[case_type.fee_type_code.to_sym])
        end.first
      end

      def offence_class
        # some/all fixed fees do not require offences and they have no bearing on calculated fee amount
        # TODO: make conditional on fee scheme version
        offence&.offence_class&.class_letter || offence&.offence_band&.description
      end

      def advocate_type
        CCR::AdvocateCategoryAdapter.code_for(advocate_category)
      end

      def fee_type_code_for(fee_type)

        ap "File: #{File.basename(__FILE__)}, Method: #{__method__}, Line: #{__LINE__}"

        if fee_type.unique_code.eql? 'FXNOC'
          ids = current_page_fees.map { |pf| pf[:fee_type_id] }
          page_fee_types = Fee::BaseFeeType.where(id: ids)
          ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
          ap page_fee_types.class
          ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
          ap page_fee_types
          ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
          primary_fee_types = page_fee_types.where(unique_code: CCR::Fee::FixedFeeAdapter::FIXED_FEE_BILL_MAPPINGS.keys)
          ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
          ap primary_fee_types
          ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
          return nil if primary_fee_types.size > 1
          fee_type = primary_fee_types.first
        else
          fee_type = case_uplift_parent if fee_type.case_uplift?
        end
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
        ap fee_type
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
        ap fee_type&.unique_code.to_sym
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
        ap fee_type.case_uplift?
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"

        mappings = [
          # CCR::Fee::BasicFeeAdapter::BASIC_FEE_BILL_MAPPINGS, # TODO: all are AGFS_FEE
          CCR::Fee::FixedFeeAdapter::FIXED_FEE_BILL_MAPPINGS,
          CCR::Fee::MiscFeeAdapter::MISC_FEE_BILL_MAPPINGS
        ].inject(&:merge)
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
        ap mappings
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"
        ap mappings[fee_type&.unique_code.to_sym][:bill_subtype]
        ap "<<<<<<<<<<<< LINE #{__LINE__} >>>>>>>>>>>>>>"

        mappings[fee_type&.unique_code.to_sym][:bill_subtype]
      end

      def case_uplift_parent
        # TODO: hacky but there is no relationship between fixed fee "primary" types
        # and their case uplift equivalent.
        # - could create relationship on models/database
        #
        Fee::BaseFeeType
          .where('description = ?', fee_type.description.gsub(' uplift', ''))
          .where.not('description ILIKE ?', '%uplift%')
          .first
      end

      def defendant_uplift_parent
      end

      def response(success, data, message = nil)
        return Response.new(success?: true, data: Data.new(amount: data), errors: nil, message: message) if success
        Response.new(success?: false, data: nil, errors: [data], message: message)
      end

      def client
        @client ||= LAA::FeeCalculator.client
      end
    end
  end
end
