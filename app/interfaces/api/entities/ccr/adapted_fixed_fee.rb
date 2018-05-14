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
      class AdaptedFixedFee < AdaptedBaseFee
        with_options(format_with: :string) do
          expose :daily_attendances
          expose :number_of_defendants
          expose :number_of_cases
        end

        expose :case_numbers

        private

        def fees_for(fee_type_unique_code)
          claim.fees.where(fee_type_id: ::Fee::BaseFeeType.where(unique_code: fee_type_unique_code))
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

        def daily_attendances
          [matching_fixed_fees.map(&:quantity).inject(:+).to_i, 1].max
        end

        def number_of_defendants
          defendant_uplift_fees.map(&:quantity).inject(:+).to_i + 1
        end

        def claim
          object.object
        end

        def fee_code
          claim.case_type.fee_type_code
        end

        def case_uplift_fee_code
          ::Fee::FixedFeeType::CASE_UPLIFT_MAPPINGS[fee_code]
        end

        def defendant_uplift_fees
          fees_for('FXNDR')
        end

        def matching_fixed_fees
          fees_for(fee_code)
        end

        def matching_case_uplift_fees
          fees_for([case_uplift_fee_code, 'FXNOC'])
        end
      end
    end
  end
end
