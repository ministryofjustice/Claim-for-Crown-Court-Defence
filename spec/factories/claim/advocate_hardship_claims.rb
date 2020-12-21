FactoryBot.define do
  factory :advocate_hardship_claim, class: 'Claim::AdvocateHardshipClaim' do
    advocate_base_setup
    case_type { nil }
    case_stage

    after(:build) do |claim|
      claim.fees << build(:basic_fee, :baf_fee, claim: claim)
      assign_external_user_as_creator(claim)
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end

    trait :rejected do
      after(:create) { |c| c.submit!; c.allocate!; c.reject! }
    end

    factory :hardship_archived_pending_review_claim do
      after(:create) { |c| advance_to_pending_review(c) }
    end
  end
end
