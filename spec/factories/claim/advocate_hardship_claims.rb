FactoryBot.define do
  factory :advocate_hardship_claim, class: 'Claim::AdvocateHardshipClaim' do
    advocate_base_setup
    case_type { nil }
    case_stage { association :case_stage, :agfs_pre_ptph }

    after(:build) do |claim|
      claim.fees << build(:basic_fee, :baf_fee, claim:)
      assign_external_user_as_creator(claim)
    end

    factory :hardship_archived_pending_review_claim do
      after(:create) { |claim| advance_to_pending_review(claim) }
    end
  end
end
