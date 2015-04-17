FactoryGirl.define do
  factory :fee do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    fee_type
  end
end
