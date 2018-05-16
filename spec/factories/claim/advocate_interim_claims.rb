FactoryBot.define do
  factory :advocate_interim_claim, class: Claim::AdvocateInterimClaim do

    advocate_base_setup

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end
    end
  end
end
