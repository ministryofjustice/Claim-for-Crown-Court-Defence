# == Schema Information
#
# Table name: vat_rates
#
#  id               :integer          not null, primary key
#  rate_base_points :integer
#  effective_date   :date
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :vat_rate, class: VatRate do
    rate_base_points 1750
    effective_date Date.new(2001, 1, 4)

    trait :for_2011_onward do
      effective_date Date.new(2011, 4, 1)
      rate_base_points 2000
    end
  end
end
