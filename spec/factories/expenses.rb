FactoryGirl.define do
  factory :expense do
    expense_type
    claim
    date { Faker::Date.between(12.days.ago, Date.today) }
    location Faker::Address.city
    quantity 1
    rate "9.99"
    hours "9.99"
    amount "9.99"

    trait :random_values do
        quantity { rand(1..10) }
        rate { rand(1.0..9.99) }
        hours { rand(1.0..10.0) }
        amount { quantity * rate * hours}
    end
  end
end
