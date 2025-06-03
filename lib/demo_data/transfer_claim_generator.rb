module DemoData
  class TransferClaimGenerator < LGFSSchemeClaimGenerator

    def generate_claim(litigator)
      super(Claim::TransferClaim, litigator)
    end

    private

    def add_claim_detail(claim)
      DemoData::TransferDetailGenerator.new(claim).generate!

    end

    def add_fees_expenses_and_disbursements(claim)
      add_transfer_fee(claim)
      add_disbursements(claim)
    end

    def add_transfer_fee(claim)
      DemoData::TransferFeeGenerator.new(claim).generate!
    end
  end
end
