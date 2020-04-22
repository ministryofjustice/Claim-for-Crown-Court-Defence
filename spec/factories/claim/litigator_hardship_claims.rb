FactoryBot.define do
  factory :litigator_hardship_claim, class: Claim::LitigatorHardshipClaim do
    advocate_base_setup

    after(:build) { |claim| post_build_actions_for_draft_final_claim(claim) }

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end
  end
end