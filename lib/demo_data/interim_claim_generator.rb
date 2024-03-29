require_relative 'lgfs_scheme_claim_generator'
require_relative 'interim_fee_generator'

module DemoData
  class InterimClaimGenerator < LGFSSchemeClaimGenerator

    def generate_claim(litigator)
      super(Claim::InterimClaim, litigator)
    end

    private

    def add_claim_detail(claim)
      # do nothing for interim claims, not needed
    end

    def add_fees_expenses_and_disbursements(claim)
      add_interim_fee(claim)
    end

    def add_interim_fee(claim)
      DemoData::InterimFeeGenerator.new(claim).generate!
    end

    def generate_case_concluded_at(claim)
      # do nothing for interim claims, not needed
    end
  end
end
