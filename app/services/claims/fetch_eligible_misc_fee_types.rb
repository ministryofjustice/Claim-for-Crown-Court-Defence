module Claims
  class FetchEligibleMiscFeeTypes
    def initialize(claim)
      @claim = claim
    end

    def call
      return nil unless claim
      return nil if claim&.interim?
      eligible_fee_types
    end

    private

    LGFS_GENERAL_ELIGIBILITY = %w[MICJA MICJP MIEVI MISPF].freeze
    LGFS_FIXED_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + %w[MIUPL]).freeze
    LGFS_TRIAL_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + Fee::MiscFeeType::TRIAL_ONLY_TYPES).freeze
    LGFS_HARDSHIP_CLAIM_ELIGIBILITY = (%w[MIEVI MISPF] + Fee::MiscFeeType::TRIAL_ONLY_TYPES).freeze

    attr_reader :claim
    delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, :agfs_scheme_12?, :hardship?, to: :claim, allow_nil: true

    def eligible_fee_types
      return eligible_agfs_misc_fee_types if agfs?
      return eligible_lgfs_misc_fee_types if lgfs?
    end

    def eligible_agfs_misc_fee_types
      return agfs_scheme_scope.supplementary if claim.supplementary?
      agfs_scheme_scope.without_supplementary_only
    end

    def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_12s if agfs_scheme_12?
      return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
      Fee::MiscFeeType.agfs_scheme_9s
    end

    def eligible_lgfs_misc_fee_types
      fee_types = if hardship?
                    lgfs_hardship_misc_fee_types
                  elsif case_type&.is_fixed_fee?
                    lgfs_fixed_fee_misc_fee_types
                  else
                    lgfs_trial_fee_misc_fee_types
                  end

      return fee_types if case_type&.is_trial_fee? || case_type.nil?
      fee_types.without_trial_fee_only
    end

    def lgfs_hardship_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_HARDSHIP_CLAIM_ELIGIBILITY)
    end

    def lgfs_fixed_fee_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_FIXED_CLAIM_ELIGIBILITY)
    end

    def lgfs_trial_fee_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_TRIAL_CLAIM_ELIGIBILITY)
    end
  end
end
