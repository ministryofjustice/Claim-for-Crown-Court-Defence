module Claims
  class FetchEligibleMiscFeeTypes
    class Lgfs < Base
      private

      GENERAL_ELIGIBILITY = %w[MICJA MICJP MIEVI MISPF].freeze
      FIXED_CLAIM_ELIGIBILITY = (GENERAL_ELIGIBILITY + %w[MIUPL]).freeze
      TRIAL_CLAIM_ELIGIBILITY = (GENERAL_ELIGIBILITY + Fee::MiscFeeType::TRIAL_ONLY_TYPES).freeze
      HARDSHIP_CLAIM_ELIGIBILITY = (TRIAL_CLAIM_ELIGIBILITY - %w[MICJA MICJP]).freeze

      def apply_filter?
        apply_clar_rep_order_filter? || apply_trial_fee_filter? || apply_transfer_guilty_plea_filter?
      end

      def fee_types_by_claim_type
        return hardship_misc_fee_types if hardship?
        return fixed_fee_misc_fee_types if case_type&.is_fixed_fee?
        trial_fee_misc_fee_types
      end

      def hardship_misc_fee_types
        Fee::MiscFeeType.lgfs.where(unique_code: HARDSHIP_CLAIM_ELIGIBILITY)
      end

      def fixed_fee_misc_fee_types
        Fee::MiscFeeType.lgfs.where(unique_code: FIXED_CLAIM_ELIGIBILITY)
      end

      def trial_fee_misc_fee_types
        Fee::MiscFeeType.lgfs.where(unique_code: TRIAL_CLAIM_ELIGIBILITY)
      end
    end
  end
end
