module Cleaners
  module CrackedDetailCleanable
    private

    def clear_cracked_details
      self.trial_fixed_notice_at = nil if trial_fixed_notice_at
      self.trial_fixed_at = nil if trial_fixed_at
      self.trial_cracked_at = nil if trial_cracked_at
      self.trial_cracked_at_third = nil if trial_cracked_at_third
    end
  end
end
