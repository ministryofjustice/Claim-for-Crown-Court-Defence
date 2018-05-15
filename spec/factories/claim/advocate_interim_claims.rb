FactoryBot.define do
  factory :advocate_interim_claim, class: Claim::AdvocateInterimClaim do

    advocate_base_setup

    trait :submitted do
      state :submitted
    end

    trait :authorised do
      after(:create) { |c| authorise_claim(c) }
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end
    end
  end
end
