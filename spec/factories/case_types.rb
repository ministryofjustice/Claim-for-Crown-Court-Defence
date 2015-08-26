# == Schema Information
#
# Table name: case_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  is_fixed_fee :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :case_type do
    # name          "Trial"
    sequence(:name) { |n| "Case Type #{n}" }
    is_fixed_fee  false

    trait :fixed_fee do
      # name           "Appeal against sentence"
      is_fixed_fee    true
    end
  end
end
