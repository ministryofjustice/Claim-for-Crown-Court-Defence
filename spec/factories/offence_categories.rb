FactoryBot.define do
  factory :offence_category do
    number 1
    description "Murder"

    trait :for_standard do
      number 17
      description "Standard Offences"
    end
  end
end
