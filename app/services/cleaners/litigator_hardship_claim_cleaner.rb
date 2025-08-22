module Cleaners
  class LitigatorHardshipClaimCleaner < BaseClaimCleaner
    def call
      clear_inapplicable_fields
    end

    private

    def clear_inapplicable_fields
      clear_ppe if case_type.present? && ppe_not_required?
    end

    def ppe_not_required?
      case_stage.unique_code.eql?('NOPTPHNOPPE') && hardship_fee.present?
    end

    def hardship_fee
      return @hardship_fee if defined?(@hardship_fee)

      @hardship_fee = fees.find_by(type: 'Fee::HardshipFee')
    end

    def clear_ppe
      hardship_fee.update(quantity: 0)
      hardship_fee.save
    end
  end
end
