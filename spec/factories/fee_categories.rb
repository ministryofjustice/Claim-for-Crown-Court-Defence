FactoryGirl.define do
  factory :fee_category do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
