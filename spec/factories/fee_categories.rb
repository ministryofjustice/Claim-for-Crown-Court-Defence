FactoryGirl.define do
  factory :fee_category do
    sequence(:abbreviation) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
