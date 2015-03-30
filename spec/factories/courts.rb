FactoryGirl.define do
  factory :court do
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    name { Faker::Company.name }
  end
end
