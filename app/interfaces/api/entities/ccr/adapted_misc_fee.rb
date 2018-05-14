module API
  module Entities
    module CCR
      class AdaptedMiscFee < AdaptedBaseFee
        with_options(format_with: :string) do
          expose :quantity
          expose :rate
          expose :amount
          expose :number_of_defendants
        end

        # TODO: dates attended not available to add to BACAV fee in CCCD interface at the
        # moment but in CCR it is the only misc fee that requires an occured_at date
        # BACAV --> a CCR AGFS_MISC_FEES, AGFS_CONFERENCE
        expose :dates_attended, using: API::Entities::CCR::DateAttended

        private

        def claim
          object.object.claim
        end

        def fees_for(fee_type_unique_code)
          claim.fees.where(fee_type_id: ::Fee::BaseFeeType.where(unique_code: fee_type_unique_code))
        end

        def fee_code
          object.fee_type.unique_code
        end

        def defendant_uplift_fee_code
          ::Fee::MiscFeeType::DEFENDANT_UPLIFT_MAPPINGS[fee_code]
        end

        def matching_defendant_uplift_fees
          fees_for(defendant_uplift_fee_code)
        end

        def number_of_defendants
          matching_defendant_uplift_fees.map(&:quantity).inject(:+).to_i + 1
        end
      end
    end
  end
end
