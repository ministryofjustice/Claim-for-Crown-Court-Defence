# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :expense_type do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
