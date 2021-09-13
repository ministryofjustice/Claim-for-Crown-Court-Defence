module Cleaners
  class AdvocateHardshipClaimCleaner < BaseClaimCleaner
    include CrackedDetailCleanable

    def clear_inapplicable_fields
      clear_cracked_details if case_type.present? && !requires_cracked_dates?
    end
  end
end
