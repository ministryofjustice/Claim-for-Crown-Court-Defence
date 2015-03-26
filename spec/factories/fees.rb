FactoryGirl.define do
  factory :fee do
    description { Faker::Lorem.word }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    quantity 1
    rate "9.99"
    amount "9.99"
    fee_type
  end
end
