# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  date            :datetime
#  location        :string(255)
#  quantity        :integer
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :expense do
    expense_type
    claim
    location Faker::Address.city
    quantity 1
    rate "9.99"
    amount "9.99"

    trait :random_values do
        quantity { rand(1..10) }
        rate { rand(1.0..9.99) }
        amount { quantity * rate}
    end
  end
end
