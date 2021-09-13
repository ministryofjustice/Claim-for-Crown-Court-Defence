class ClaimCleanerService
  module CrackedDetailCleanable
    private

    def clear_cracked_details
      claim.trial_fixed_notice_at = nil if trial_fixed_notice_at
      claim.trial_fixed_at = nil if trial_fixed_at
      claim.trial_cracked_at = nil if trial_cracked_at
      claim.trial_cracked_at_third = nil if trial_cracked_at_third
    end
  end
end
