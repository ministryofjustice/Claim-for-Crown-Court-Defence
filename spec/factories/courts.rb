FactoryGirl.define do
  factory :court do
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    sequence(:name) { |n| "Faker::Company.name-#{n}" }
  end
end
