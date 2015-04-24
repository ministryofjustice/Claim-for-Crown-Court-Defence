FactoryGirl.define do
  factory :document_type do
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
