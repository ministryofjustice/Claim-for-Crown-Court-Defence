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
  end
end
