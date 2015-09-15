# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :location do
    name { Faker::Address.city }
  end
end
