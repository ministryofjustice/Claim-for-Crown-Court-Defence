FactoryGirl.define do
  factory :scheme do
    sequence(:name) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
