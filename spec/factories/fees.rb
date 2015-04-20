FactoryGirl.define do
  factory :fee do
    claim
    fee_type
    quantity 1
    rate "9.99"
    amount "9.99"
  end
end
