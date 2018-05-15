FactoryBot.define do
  factory :advocate_interim_claim, class: Claim::AdvocateInterimClaim do

    advocate_base_setup

    trait :submitted do
      state :submitted
    end

    trait :authorised do
      state :authorised
    end
  end
end
