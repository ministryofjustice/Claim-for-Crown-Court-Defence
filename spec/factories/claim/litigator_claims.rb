FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    litigator_base_setup
    claim_state_common_traits

    after(:build) do |claim|
      claim.fees << build(:misc_fee, claim: claim) # fees required for valid claims
    end
  end
end
