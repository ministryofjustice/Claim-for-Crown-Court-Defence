FactoryBot.define do
  factory :advocate_hardship_claim, class: 'Claim::AdvocateHardshipClaim' do
    advocate_base_setup
    case_type { nil }
    case_stage

    after(:build) do |claim|
      claim.fees << build(:basic_fee, :baf_fee, claim: claim)
      assign_external_user_as_creator(claim)
    end

    trait :draft do
      after(:build) do |claim|
        claim.certification = nil if claim.certification
      end
    end

    trait :authorised do
      after(:create) { |claim| authorise_claim(claim) }
    end

    trait :rejected do
      after(:create) { |claim| claim.submit!; claim.allocate!; claim.reject! }
    end

    factory :hardship_archived_pending_review_claim do
      after(:create) { |claim| advance_to_pending_review(claim) }
    end
  end
end
