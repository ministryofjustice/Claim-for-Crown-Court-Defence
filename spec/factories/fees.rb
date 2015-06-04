# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  rate        :decimal(, )
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

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

    trait :basic do
      fee_type        { FactoryGirl.create :fee_type, :basic }
    end

    trait :misc do
      fee_type        { FactoryGirl.create :fee_type, :misc }
    end

    trait :fixed do
      fee_type        { FactoryGirl.create :fee_type, :fixed }
    end

    trait :all_zero do
      quantity 0
      rate 0
      amount 0
    end

  end

end
