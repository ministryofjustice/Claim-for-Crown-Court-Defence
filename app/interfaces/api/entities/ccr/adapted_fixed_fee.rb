# 1. CCCD can, potentially, have one or more fixed fees of a type
# matching a single CCR fixed bill type.
# 2. In addition CCCD can have one or more fixed fees of the uplift variety of that
# case type.
#
#   e.g. CCCD could have 2 FXCBR and 2 FXCBU
#
# These need to be consolidated into one CCR bill of
# type/subtype AGFS_FEE, <CCR_FIXED_FEE_BILL_SUBTYPE>
#   e.g. AGFS_FEE, AGFS_ORDER_BRCH
#
module API
  module Entities
    module CCR
      class AdaptedFixedFee < API::Entities::CCR::AdaptedBaseFee
        with_options(format_with: :string) do
          # derived/transformed data exposures
          expose :daily_attendances
          expose :number_of_defendants
          expose :number_of_cases
        end

        expose :case_numbers

        private

        UPLIFT_MAPPINGS = {
          FXACV: 'FXACU',
          FXASE: 'FXASU',
          FXCBR: 'FXCBU',
          FXCSE: 'FXCSU'
        }.with_indifferent_access.freeze

        def fees_for(fee_type_unique_code)
          object.fees.where(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(fee_type_unique_code))
        end

        # CCR requires total number of cases (claim's + additional's for the fee)
        def number_of_cases
          case_numbers.split(',').size + 1
        end

        def case_numbers
          return @case_numbers if @case_numbers
          @case_numbers = []
          matching_case_uplift_fees.each_with_object(@case_numbers) do |fee, memo|
            fee.case_numbers.split(',').inject(memo, :<<)
          end
          @case_numbers = @case_numbers.map(&:strip).uniq.join(',')
        end

        # determine daily attendances from what? quantity of "main" fixed fee? check
        def daily_attendances
          matching_fixed_fees.map(&:quantity).inject(:+).to_i
        end

        # FIXME: currently have to use actual defendant count but
        # really this value should be specifiable by the claimant (new field?)
        def number_of_defendants
          claim.defendants.count
        end

        def claim
          object.instance_variable_get :@object
        end

        def fee_code
          claim.case_type.fee_type_code
        end

        def uplift_fee_code
          UPLIFT_MAPPINGS[fee_code]
        end

        def matching_fixed_fees
          claim.fixed_fees.where(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(fee_code))
        end

        def matching_case_uplift_fees
          claim.fixed_fees.where(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(uplift_fee_code))
        end
      end
    end
  end
end
