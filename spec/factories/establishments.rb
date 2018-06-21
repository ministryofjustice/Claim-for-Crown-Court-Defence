FactoryBot.define do
  factory :establishment do
    name { Faker::Lorem.word }
    category { Establishment::CATEGORIES.sample }
    postcode { Faker::Address.postcode }

    trait :prison do
      category 'prison'
    end

    trait :hospital do
      category 'hospital'
    end

    trait :magistrates_court do
      category 'magistrates_court'
    end

    trait :crown_court do
      category 'crown_court'
    end
  end
end
