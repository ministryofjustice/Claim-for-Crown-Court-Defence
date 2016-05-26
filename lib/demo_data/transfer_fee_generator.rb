require_relative 'disbursement_generator'

module DemoData
  class TransferFeeGenerator

    def initialize(claim)
      @claim     = claim
      @fee_types = Fee::TransferFeeType.all
    end

    def generate!
      add_fee
    end

    private

    def add_fee
      fee_type = @fee_types.sample
      fee = Fee::TransferFee.new(claim: @claim, fee_type: fee_type)
      fee.amount   = rand(250.0..5000.0).round(2)

      @claim.save
      fee.save
    end
  end
end
