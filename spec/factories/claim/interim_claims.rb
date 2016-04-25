FactoryGirl.define do
  factory :interim_claim, class: Claim::InterimClaim do

    litigator_base_setup
    claim_state_common_traits
  end

  trait :interim_fee do
    after(:build) do |claim|
      claim.fees << build(:interim_fee, :effective_pcmh, claim: claim)
    end
    after(:create) { |c| c.submit! }
  end

  trait :warrant_fee do
    after(:build) do |claim|
      claim.fees << build(:warrant_fee, amount: 10.0)
      claim.fees << build(:interim_fee, :warrant, claim: claim)
    end
    after(:create) { |c| c.submit! }
  end

  trait :disbursement_only_fee do
    after(:build) do |claim|
      claim.disbursements << build_list(:disbursement, 1)
      claim.fees << build(:interim_fee, :disbursement, claim: claim)
    end
    after(:create) { |c| c.submit! }
  end

end
