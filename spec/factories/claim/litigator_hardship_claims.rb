FactoryBot.define do
  factory :litigator_hardship_claim, class: Claim::LitigatorHardshipClaim do
    litigator_base_setup
    case_type { nil }
    case_stage { build :case_stage, :pre_ptph_or_ptph_adjourned }

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

    trait :redetermination do
      after(:create) do |c|
        frozen_time do
          c.submit!
          c.allocate!
          c.assessment.update(fees: 24.2, expenses: 8.5)
          c.authorise!
          c.redetermine!
        end
      end
    end
  end
end
