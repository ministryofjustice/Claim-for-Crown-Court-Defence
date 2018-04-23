# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :location do
    name { Faker::Address.unique.city }
  end
end
