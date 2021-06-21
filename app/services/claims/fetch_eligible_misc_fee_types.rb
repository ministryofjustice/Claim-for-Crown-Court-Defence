module Claims
  class FetchEligibleMiscFeeTypes
    def initialize(claim)
      @claim = claim
    end

    def call
      return unless claim
      return [] if claim&.interim?
      eligible_fee_types
    end

    private

    LGFS_GENERAL_ELIGIBILITY = %w[MICJA MICJP MIEVI MISPF].freeze
    LGFS_FIXED_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + %w[MIUPL]).freeze
    LGFS_TRIAL_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + Fee::MiscFeeType::TRIAL_ONLY_TYPES).freeze
    LGFS_HARDSHIP_CLAIM_ELIGIBILITY = (LGFS_TRIAL_CLAIM_ELIGIBILITY - %w[MICJA MICJP]).freeze

    attr_reader :claim
    delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, :agfs_scheme_12?, :hardship?, to: :claim, allow_nil: true

    def eligible_fee_types
      return eligible_agfs_misc_fee_types if agfs?
      return eligible_lgfs_misc_fee_types if lgfs?
    end

    def eligible_agfs_misc_fee_types
      trial_fee_filter(agfs_fee_types_by_claim_type)
    end

    def agfs_fee_types_by_claim_type
      return agfs_scheme_scope.supplementary if claim.supplementary?
      agfs_scheme_scope.without_supplementary_only
    end

    def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_12s if agfs_scheme_12?
      return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
      Fee::MiscFeeType.agfs_scheme_9s
    end

    def eligible_lgfs_misc_fee_types
      clar_rep_order_filter(
        trial_fee_filter(
          lgfs_fee_types_by_claim_type
        )
      )
    end

    def lgfs_fee_types_by_claim_type
      return lgfs_hardship_misc_fee_types if hardship?
      return lgfs_fixed_fee_misc_fee_types if case_type&.is_fixed_fee?
      lgfs_trial_fee_misc_fee_types
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

    def trial_fee_filter(relation)
      return relation if case_type&.is_trial_fee? || case_type.nil?
      relation.without_trial_fee_only
    end

    def clar_rep_order_filter(relation)
      return relation if claim&.earliest_representation_order_date.nil?
      return relation if claim.earliest_representation_order_date >= Settings.clar_release_date.to_date.beginning_of_day
      relation.without_trial_fee_only
    end
  end
end
