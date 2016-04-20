FactoryGirl.define do
  factory :interim_claim, class: Claim::InterimClaim do

    litigator_base_setup
    claim_state_common_traits
  end
end
