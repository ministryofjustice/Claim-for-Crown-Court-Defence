# == Schema Information
#
# Table name: fee_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string
#

FactoryGirl.define do
  factory :fee_category do
    sequence(:abbreviation) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end

  factory :basic_fee_category, class: FeeCategory do
    abbreviation           'BASIC'
    name                   'Basic fees'
  end

  factory :fixed_fee_category, class: FeeCategory do
    abbreviation           'FIXED'
    name                   'Fixed fees'
  end

  factory :misc_fee_category, class: FeeCategory do
    abbreviation           'MISC'
    name                   'Miscellaneous fees'
  end
end

