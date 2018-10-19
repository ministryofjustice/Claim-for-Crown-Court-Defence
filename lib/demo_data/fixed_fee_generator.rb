module DemoData
  class FixedFeeGenerator

    def initialize(claim)
      @claim = claim
    end

    def generate!
      fee_type = @claim.case_type.fixed_fee_type
      fee = Fee::FixedFee.new(claim: @claim, fee_type: fee_type, amount: rand(100.0..2500.0).round(2), date: single_attendance_date)
      fee.save!
    end

    private

    def single_attendance_date
      @claim.earliest_representation_order_date + 1.day
    end
  end
end
