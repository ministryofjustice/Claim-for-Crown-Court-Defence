FactoryBot.define do
  factory :advocate_interim_claim, class: Claim::AdvocateInterimClaim do
    court
    case_number { random_case_number }
    creator { build(:external_user, :advocate) }
    external_user { creator }

    trait :submitted do
      state :submitted
    end
  end
end
