module Cleaners
  class AdvocateSupplementaryClaimCleaner < BaseClaimCleaner
    include IneligibleMiscFeesCleanable

    def call
      destroy_invalid_fees
    end

    private

    def destroy_invalid_fees
      clear_ineligible_misc_fees
    end
  end
end
