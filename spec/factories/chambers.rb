FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:account_number) { |n| "#{n}-#{Time.now.to_i}" }
  end
end
