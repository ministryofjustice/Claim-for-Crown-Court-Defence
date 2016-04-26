module DemoData
  class InterimFeeGenerator

    def initialize(claim)
      @claim     = claim
      @fee_types = Fee::InterimFeeType.lgfs
    end

    def generate!
      add_fee
    end

    private

    def add_fee
      fee_type = @fee_types.sample
      fee = Fee::InterimFee.new(claim: @claim, fee_type: fee_type)

      setup_fee(fee)

      @claim.save
      fee.save
    end

    def setup_fee(fee)
      if fee.is_interim_warrant?
        @claim.fees << FactoryGirl.build(:warrant_fee, amount: rand(100.0..2500.0))
      end

      if fee.is_disbursement? || fee.is_effective_pcmh?
        @claim.disbursements << FactoryGirl.build_list(:disbursement, rand(1..3))
      end

      if fee.is_effective_pcmh?
        @claim.effective_pcmh_date = rand(1..5).months.ago
      end

      if fee.is_trial_start?
        @claim.first_day_of_trial = rand(1..5).months.ago
        @claim.estimated_trial_length = rand(3..15)
      end

      if fee.is_retrial_start?
        @claim.retrial_started_at = rand(1..5).months.ago
        @claim.retrial_estimated_length = rand(3..15)
      end

      if fee.is_retrial_new_solicitor?
        @claim.legal_aid_transfer_date = rand(1..5).months.ago
        @claim.trial_concluded_at = rand(1..5).months.ago
      end

      unless fee.is_disbursement? || fee.is_interim_warrant?
        fee.quantity = rand(10..50)
        fee.amount   = rand(1000.0..5000.0)
      end
    end
  end
end
