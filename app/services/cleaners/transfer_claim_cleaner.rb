module Cleaners
  class TransferClaimCleaner < BaseClaimCleaner
    def call
      destroy_invalid_fees
    end

    private

    def destroy_invalid_fees
      fees.where(type: 'Fee::GraduatedFee').destroy_all
    end
  end
end
