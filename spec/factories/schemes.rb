# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :scheme do
    sequence(:name) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
