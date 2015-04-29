FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:account_number) { |n| "123456-#{n}" }
  end
end
