require_relative 'lgfs_scheme_claim_generator'
require_relative 'fixed_fee_generator'
require_relative 'fee_generator'

module DemoData
  class LitigatorClaimGenerator < LgfsSchemeClaimGenerator

    def generate_claim(litigator)
      super(Claim::LitigatorClaim, litigator)
    end

    private

    def add_claim_detail(claim)
      super
    end

    def add_fixed_fees(claim)
      FixedFeeGenerator.new(claim).generate!
    end

    def add_misc_fees(claim)
      FeeGenerator.new(claim, Fee::MiscFeeType, misc_fee_types).generate!
    end

    # Case uplift requires filling case numbers
    # To simplify this generator we avoid this fee type
    #
    def misc_fee_types
      Fee::MiscFeeType.lgfs.to_a.reject!{ |ft| ft.case_uplift? }
    end

    def add_fees_expenses_and_disbursements(claim)
      add_fixed_fees(claim) if claim.case_type.is_fixed_fee?
      add_misc_fees(claim)
      add_expenses(claim)
      add_disbursements(claim)
    end
  end
end
