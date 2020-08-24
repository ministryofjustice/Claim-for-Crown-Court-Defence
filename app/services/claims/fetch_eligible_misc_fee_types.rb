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
    LGFS_FIXED_FEE_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + %w[MIUPL]).freeze
    LGFS_GRADUATED_FEE_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + %w[MIUMU MIUMO]).freeze
    LGFS_HARDSHIP_FEE_ELIGIBILITY = %w[MIEVI MISPF].freeze

    attr_reader :claim
    delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, :agfs_scheme_12?, :hardship?, to: :claim, allow_nil: true

    def eligible_fee_types
      return eligible_agfs_misc_fee_types if agfs?
      return elgible_lgfs_hardship_misc_fee_types if lgfs? && hardship?
      return eligible_lgfs_misc_fee_types if lgfs?
    end

    def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_12s if agfs_scheme_12?
      return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
      Fee::MiscFeeType.agfs_scheme_9s
    end

    def eligible_agfs_misc_fee_types
      return agfs_scheme_scope.supplementary if claim.supplementary?
      agfs_scheme_scope.without_supplementary_only
    end

    def elgible_lgfs_hardship_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_HARDSHIP_FEE_ELIGIBILITY)
    end

    def eligible_lgfs_misc_fee_types
      return lgfs_fixed_fee_misc_fee_types if case_type&.is_fixed_fee?
      lgfs_graduated_fee_misc_fee_types
    end

    def lgfs_fixed_fee_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_FIXED_FEE_ELIGIBILITY)
    end

    def lgfs_graduated_fee_misc_fee_types
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_GRADUATED_FEE_ELIGIBILITY)
    end
  end
end
