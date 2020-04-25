FactoryBot.define do
  factory :advocate_hardship_claim, class: Claim::AdvocateHardshipClaim do
    advocate_base_setup
    case_type { nil }
    case_stage

    after(:build) { |claim| post_build_actions_for_draft_final_claim(claim) }

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end
  end
end
