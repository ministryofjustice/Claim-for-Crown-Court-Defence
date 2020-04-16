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

    LGFS_MISC_FEE_ELIGIBILITY = %w[MICJA MICJP MIEVI MISPF].freeze

    attr_reader :claim
    delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, to: :claim, allow_nil: true

    def eligible_fee_types
      return eligible_agfs_misc_fee_types if agfs?
      return eligible_lgfs_misc_fee_types if lgfs?
    end

    def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
      Fee::MiscFeeType.agfs_scheme_9s
    end

    def eligible_agfs_misc_fee_types
      return agfs_scheme_scope.supplementary if claim.supplementary?
      agfs_scheme_scope.without_supplementary_only
    end

    def eligible_lgfs_misc_fee_types
      return Fee::MiscFeeType.lgfs if case_type&.is_fixed_fee?
      Fee::MiscFeeType.lgfs.where(unique_code: LGFS_MISC_FEE_ELIGIBILITY)
    end
  end
end
