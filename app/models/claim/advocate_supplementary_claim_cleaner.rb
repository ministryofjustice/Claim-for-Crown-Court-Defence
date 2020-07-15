module Claim
  class AdvocateSupplementaryClaimCleaner
    attr_accessor :claim

    delegate_missing_to :claim

    def initialize(claim)
      @claim = claim
    end

    def call
      destroy_ineligible_misc_fees
    end

    private

    def destroy_ineligible_misc_fees
      misc_fees.delete(ineligible_misc_fees)
    end

    def ineligible_misc_fees
      eligbile_fee_types = Claims::FetchEligibleMiscFeeTypes.new(self).call
      misc_fees.reject do |fee|
        eligbile_fee_types.map(&:unique_code).include?(fee.fee_type.unique_code)
      end
    end
  end
end
