FactoryBot.define do
  factory :litigator_hardship_claim, class: 'Claim::LitigatorHardshipClaim' do
    litigator_base_setup
    case_type { nil }
    case_stage { build(:case_stage, :pre_ptph_or_ptph_adjourned) }

    after(:build) { |claim| post_build_actions_for_draft_hardship_claim(claim) }

    trait :with_hardship_fee do
      after(:build) do |claim|
        claim.fees << build(:hardship_fee, quantity: 51, amount: 97.9)
      end
    end
  end
end
