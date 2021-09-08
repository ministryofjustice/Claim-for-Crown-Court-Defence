module Claim
  class LitigatorHardshipClaimCleaner
    attr_accessor :claim

    delegate_missing_to :claim

    def initialize(claim)
      @claim = claim
    end

    def call
      clear_inapplicable_fields
    end

    private

    def clear_inapplicable_fields
      clear_ppe if case_type.present? && ppe_not_required?
    end

    def ppe_not_required?
      claim.case_stage.unique_code.eql?('NOPTPHNOPPE') && has_hardship_fee?
    end

    def has_hardship_fee?
      hardship_fee.present?
    end

    def hardship_fee
      @hardship_fee ||= claim.fees.find_by(type: 'Fee::HardshipFee')
    end

    def clear_ppe
      hardship_fee.update(quantity: 0)
      hardship_fee.save
    end
  end
end
