require_relative 'lgfs_scheme_claim_generator'

module DemoData
  class LitigatorClaimGenerator < LgfsSchemeClaimGenerator

    def generate_claim(litigator)
      super(Claim::LitigatorClaim, litigator)
    end

    private

    def add_claim_detail(claim)
      super
    end

    def add_fees_expenses_and_disbursements(claim)
      add_fixed_fees(claim) if claim.case_type.is_fixed_fee?
      add_misc_fees(claim)
      add_expenses(claim)
      add_disbursements(claim)
    end
  end
end
