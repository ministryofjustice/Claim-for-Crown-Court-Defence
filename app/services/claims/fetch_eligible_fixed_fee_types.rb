module Claims
  class FetchEligibleFixedFeeTypes
    def initialize(claim)
      @claim = claim
    end

    def call
      return nil unless claim
      return nil if claim&.interim?
      eligible_fee_types
    end

    private

    AGFS_FIXED_FEE_ELIGIBILITY = {
      FXACV: %w[FXACV FXNOC FXNDR FXSAF FXADJ],
      FXASE: %w[FXASE FXNOC FXNDR FXSAF FXADJ],
      FXCBR: %w[FXCBR FXNOC FXNDR FXSAF FXADJ],
      FXCSE: %w[FXCSE FXNOC FXNDR FXSAF FXADJ],
      FXCON: %w[FXCON FXSAF FXADJ],
      FXENP: %w[FXENP FXNOC FXNDR]
    }.with_indifferent_access.freeze

    delegate :case_type, :agfs?, :lgfs?, to: :claim, allow_nil: true
    attr_reader :claim

    def eligible_fee_types
      return eligible_agfs_fixed_fee_types if agfs?
      return eligible_lgfs_fixed_fee_types if lgfs?
    end

    def eligible_agfs_fixed_fee_types
      Fee::FixedFeeType.agfs.where(unique_code: AGFS_FIXED_FEE_ELIGIBILITY[case_type&.fee_type_code])
    end

    def eligible_lgfs_fixed_fee_types
      Fee::FixedFeeType.lgfs
    end
  end
end
