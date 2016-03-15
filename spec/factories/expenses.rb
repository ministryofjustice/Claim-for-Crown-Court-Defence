# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :float
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  reason_id       :integer
#  reason_text     :string
#  schema_version  :integer
#

FactoryGirl.define do
  factory :expense do
    expense_type
    claim
    location Faker::Address.city
    quantity 1
    rate "9.99"
    amount "9.99"
    reason_id 1

    trait :with_date_attended do
      after(:build) do |expense|
        expense.dates_attended << build(:date_attended, attended_item: expense)
      end
    end

    trait :random_values do
        quantity { rand(1..10) }
        rate { rand(1.0..9.99) }
        amount { quantity * rate}
    end


  end
end
