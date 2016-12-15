require_relative 'lgfs_scheme_claim_generator'
require_relative 'transfer_fee_generator'
require_relative 'transfer_detail_generator'

module DemoData
  class TransferClaimGenerator < LgfsSchemeClaimGenerator

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
