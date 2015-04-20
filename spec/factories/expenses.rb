FactoryGirl.define do
  factory :expense do
    expense_type
    claim
    date "2015-03-26 14:08:17"
    location "MyString"
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
