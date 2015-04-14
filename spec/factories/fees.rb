FactoryGirl.define do
  factory :fee do
    description { Faker::Lorem.word }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    fee_type
  end
end
