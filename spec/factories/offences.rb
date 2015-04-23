FactoryGirl.define do
  factory :offence do
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
    offence_class 'A'
  end
end
