module Claim
  class LitigatorClaim < BaseClaim

    validates_with ::Claim::LitigatorClaimValidator
    validates_with ::Claim::LitigatorClaimSubModelValidator

  end
end