require_relative 'disbursement_generator'

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
        fee.warrant_issued_date = rand(1..5).months.ago
        fee.warrant_executed_date = fee.warrant_issued_date + rand(1..7)
      end

      if fee.is_disbursement? || fee.is_effective_pcmh?
        @claim.disbursements << disbursements(1..3)
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

      unless fee.is_disbursement?
        fee.quantity = rand(10..50) unless fee.is_interim_warrant?
        fee.amount   = rand(1000.0..5000.0).round(2)
      end
    end

    def disbursements(range)
      DisbursementGenerator.new.generate!(range)
    end
  end
end
