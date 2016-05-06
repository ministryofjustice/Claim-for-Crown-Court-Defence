# This class is responsible for adding a fixed fee to match the case type 
# on the claim, and remove any fixed fees that were added as a result
# of a previous value in the case type on the claim
#
module Fee
  class FixedFeeAdder
    
    def initialize(claim)
      @claim = claim
    end
    
    def add!
      return unless @claim.case_type
      return unless @claim.case_type.is_fixed_fee?
      required_fixed_fee_type = @claim.case_type.fixed_fee_type
      remove_other_fixed_fees_from_claim(required_fixed_fee_type)
      add_required_fixed_fee(required_fixed_fee_type)
    end

    private

    def remove_other_fixed_fees_from_claim(required_fixed_fee_type)
      @claim.fixed_fees.each do |fee|
        next if fee.fee_type == required_fixed_fee_type
        fee.persisted? ? fee.destroy! : @claim.fixed_fees.delete(fee)
      end
    end

    def add_required_fixed_fee(required_fixed_fee_type)
      return if @claim.fixed_fees.map(&:fee_type).include?(required_fixed_fee_type)
      @claim.fixed_fees << Fee::FixedFee.new(fee_type: required_fixed_fee_type)
    end
  end
end


