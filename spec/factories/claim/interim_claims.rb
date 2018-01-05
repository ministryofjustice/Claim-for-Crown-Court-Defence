FactoryBot.define do
  factory :interim_claim, class: Claim::InterimClaim do

    litigator_base_setup
    claim_state_common_traits
    case_concluded_at nil
  end

  trait :interim_effective_pcmh_fee do
    after(:build) do |claim|
      claim.fees << build(:interim_fee, :effective_pcmh, claim: claim)
      claim.effective_pcmh_date = 2.days.ago
    end
  end

  trait :interim_warrant_fee do
    after(:build) do |claim|
      claim.fees << build(:interim_fee, :warrant, claim: claim)
    end
  end

  trait :disbursement_only_fee do
    after(:build) do |claim|
      claim.disbursements << build_list(:disbursement, 1)
      claim.fees << build(:interim_fee, :disbursement, claim: claim)
    end
  end

  trait :submitted do
    after(:create) { |c| c.submit! }
  end
end
