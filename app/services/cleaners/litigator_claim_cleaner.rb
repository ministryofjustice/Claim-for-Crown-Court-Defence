module Cleaners
  class LitigatorClaimCleaner < BaseClaimCleaner
    def call
      destroy_invalid_fees
    end

    private

    def destroy_invalid_fees
      return if case_type.blank?

      if case_type.is_fixed_fee?
        graduated_fee&.destroy
        self.graduated_fee = nil
      else
        fixed_fee&.destroy
        self.fixed_fee = nil
      end
    end
  end
end
