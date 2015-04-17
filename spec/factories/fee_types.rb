FactoryGirl.define do
  factory :fee_type do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
