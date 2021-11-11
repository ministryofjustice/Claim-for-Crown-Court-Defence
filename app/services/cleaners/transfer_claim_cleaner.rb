module Cleaners
  class TransferClaimCleaner < BaseClaimCleaner
    include IneligibleMiscFeesCleanable

    def call
      clear_graduate_fees
      clear_ineligible_misc_fees
    end

    private

    def clear_graduate_fees
      fees.where(type: 'Fee::GraduatedFee').destroy_all
    end
  end
end
