module Claim
  class AdvocateSupplementaryClaimCleaner
    attr_accessor :claim

    delegate  :misc_fees,
              :interim?,
              :agfs?,
              :supplementary?,
              :agfs_reform?,
              to: :claim

    def initialize(claim)
      @claim = claim
    end

    def call
      destroy_ineligible_misc_fees
    end

    private

    def destroy_ineligible_misc_fees
      eligbile_fees = Claims::FetchEligibleMiscFeeTypes.new(self).call
      misc_fees.each do |fee|
        misc_fees.delete(fee) unless eligbile_fees.map(&:code).include?(fee.fee_type_code)
      end
    end
  end
end
