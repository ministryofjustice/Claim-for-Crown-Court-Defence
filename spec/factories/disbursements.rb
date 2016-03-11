# == Schema Information
#
# Table name: disbursements
#
#  id                   :integer          not null, primary key
#  disbursement_type_id :integer
#  claim_id             :integer
#  net_amount           :decimal(, )
#  vat_amount           :decimal(, )
#  created_at           :datetime
#  updated_at           :datetime
#

FactoryGirl.define do
  factory :disbursement do
    disbursement_type
    claim
    net_amount "9.99"
    vat_amount "1.99"

    trait :random_values do
      net_amount { rand(1.0..9.99) }
      vat_amount { rand(1.0..9.99) }
    end
  end
end
