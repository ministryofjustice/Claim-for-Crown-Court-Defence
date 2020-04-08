module Claim
  class AdvocateHardshipClaimCleaner
    attr_accessor :claim

    delegate  :case_type,
              :requires_cracked_dates?,
              :trial_fixed_notice_at,
              :trial_fixed_at,
              :trial_cracked_at,
              :trial_cracked_at_third,
              to: :claim

    def initialize(claim)
      @claim = claim
    end

    def call
      clear_inapplicable_fields
    end

    private

    # TODO: Hardship claim - can be shared with advocate final claims
    def clear_inapplicable_fields
      clear_cracked_details if case_type.present? && !requires_cracked_dates?
    end

    # TODO: Hardship claim - can be shared with advocate final claims
    def clear_cracked_details
      claim.trial_fixed_notice_at = nil if trial_fixed_notice_at
      claim.trial_fixed_at = nil if trial_fixed_at
      claim.trial_cracked_at = nil if trial_cracked_at
      claim.trial_cracked_at_third = nil if trial_cracked_at_third
    end
  end
end
