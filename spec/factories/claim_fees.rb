FactoryGirl.define do
  factory :claim_fee do
    claim
    fee
    quantity 1
    rate "9.99"
    amount "9.99"
  end
end
