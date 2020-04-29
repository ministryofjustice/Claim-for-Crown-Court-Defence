FactoryBot.define do
  factory :advocate_hardship_claim, class: Claim::AdvocateHardshipClaim do
    advocate_base_setup
    case_type { nil }
    case_stage

    after(:build) do |claim|
      set_creator(claim)
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end
  end
end
