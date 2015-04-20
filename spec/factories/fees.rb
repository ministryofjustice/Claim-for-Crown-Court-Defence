FactoryGirl.define do
  factory :fee do
    claim
    fee_type
    quantity 1
    rate "9.99"
    amount "9.99"

    trait :random_values do
      quantity { rand(1..10) }
      rate { rand(1.0..9.99) }
      amount { quantity * rate }
    end

  end
end
