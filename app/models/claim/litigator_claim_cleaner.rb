module Claim
  class LitigatorClaimCleaner
    attr_accessor :claim

    delegate  :case_type,
              :graduated_fee,
              :fixed_fee,
              to: :claim

    def initialize(claim)
      @claim = claim
    end

    def call
      destroy_all_invalid_fee_types
    end

    private

    def destroy_all_invalid_fee_types
      return if case_type.blank?

      if case_type.is_fixed_fee?
        graduated_fee&.destroy
        claim.graduated_fee = nil
      else
        fixed_fee&.destroy
        claim.fixed_fee = nil
      end
    end
  end
end
