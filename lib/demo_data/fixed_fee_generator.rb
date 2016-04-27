module DemoData
  class FixedFeeGenerator

    def initialize(claim)
      @claim = claim
    end

    def generate!
      fee_type = @claim.case_type.fixed_fee_type
      fee = Fee::FixedFee.new(claim: @claim, fee_type: fee_type, amount: rand(100.0..2500.0).round(2))

      if fee_type.children.any?
        fee.sub_type_id = fee_type.children.sample.id
      end

      fee.save
    end
  end
end
