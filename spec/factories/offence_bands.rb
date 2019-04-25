FactoryBot.define do
  factory :offence_band do
    number { 1 }
    description { '1.1' }
    offence_category

    trait :for_standard do
      number { 1 }
      description { '17.1' }
      offence_category { association(:offence_category, :for_standard) }
    end
  end
end
