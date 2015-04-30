FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:account_number) { |n| "#{Faker::Number.number(10)}-#{n}" }
  end
end
