# == Schema Information
#
# Table name: fee_categories
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#

FactoryGirl.define do
  factory :fee_category do
    sequence(:abbreviation) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
