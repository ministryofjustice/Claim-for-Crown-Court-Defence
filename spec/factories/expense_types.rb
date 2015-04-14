FactoryGirl.define do
  factory :expense_type do
    sequence(:name) { |n| "Faker::Lorem.word-#{n}" }
  end
end
