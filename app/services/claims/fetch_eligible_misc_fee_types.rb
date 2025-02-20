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

    LGFS_GENERAL_ELIGIBILITY = %w[MICJA MICJP MIEVI MISPF].freeze
    LGFS_FIXED_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + %w[MIUPL]).freeze
    LGFS_TRIAL_CLAIM_ELIGIBILITY = (LGFS_GENERAL_ELIGIBILITY + Fee::MiscFeeType::TRIAL_ONLY_TYPES).freeze
    LGFS_HARDSHIP_CLAIM_ELIGIBILITY = (LGFS_TRIAL_CLAIM_ELIGIBILITY - %w[MICJA MICJP]).freeze

    private_constant :LGFS_GENERAL_ELIGIBILITY, :LGFS_FIXED_CLAIM_ELIGIBILITY, :LGFS_TRIAL_CLAIM_ELIGIBILITY,
                     :LGFS_HARDSHIP_CLAIM_ELIGIBILITY

    private

    attr_reader :claim
    delegate :case_type, :agfs?, :lgfs?, :agfs_reform?, :agfs_scheme_12?, :agfs_scheme_13?, :agfs_scheme_14?,
             :agfs_scheme_15?, :agfs_scheme_16?, :hardship?,
             to: :claim, allow_nil: true

    def eligible_fee_types
      return eligible_agfs_misc_fee_types if agfs?
      eligible_lgfs_misc_fee_types if lgfs?
    end

    def eligible_agfs_misc_fee_types
      filter_trial_only_types(agfs_fee_types_by_claim_type, apply_trial_fee_filter?)
    end

    def agfs_fee_types_by_claim_type
      return agfs_scheme_scope.supplementary if claim.supplementary?
      agfs_scheme_scope.without_supplementary_only
    end

    def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_16s if agfs_scheme_16?
      return Fee::MiscFeeType.agfs_scheme_15s if agfs_scheme_15?
      return Fee::MiscFeeType.agfs_scheme_14s if agfs_scheme_14?
      return Fee::MiscFeeType.agfs_scheme_13s if agfs_scheme_13?
      return Fee::MiscFeeType.agfs_scheme_12s if agfs_scheme_12?
      return Fee::MiscFeeType.agfs_scheme_10s if agfs_reform?
      Fee::MiscFeeType.agfs_scheme_9s
    end

    def eligible_lgfs_misc_fee_types
      filter_trial_only_types(lgfs_fee_types_by_claim_type, apply_filter_for_lgfs?)
    end

    def apply_filter_for_lgfs?
      apply_clar_rep_order_filter? || apply_trial_fee_filter? || apply_transfer_guilty_plea_filter?
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

    def apply_trial_fee_filter?
      case_type && !case_type.is_trial_fee?
    end

    def apply_clar_rep_order_filter?
      claim&.earliest_representation_order_date &&
        (claim.earliest_representation_order_date < Settings.clar_release_date.to_date.beginning_of_day)
    end

    def apply_transfer_guilty_plea_filter?
      claim.transfer? && claim.transfer_detail&.case_conclusion == 'Guilty plea'
    end

    def filter_trial_only_types(relation, filter)
      filter ? relation.without_trial_fee_only : relation
    end
  end
end
