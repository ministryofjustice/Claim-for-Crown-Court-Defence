FactoryBot.define do
  factory :litigator_hardship_claim, class: Claim::LitigatorHardshipClaim do
    litigator_base_setup

    after(:build) { |claim| post_build_actions_for_draft_hardship_claim(claim) }

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end

    trait :with_hardship_fee do
      after(:build) do |claim|
        claim.fees << build(:hardship_fee, quantity: 51, amount: 97.9)
      end
    end
  end
end
