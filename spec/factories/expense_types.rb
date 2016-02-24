# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  roles      :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :expense_type do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }

    roles ['agfs']
  end
end
