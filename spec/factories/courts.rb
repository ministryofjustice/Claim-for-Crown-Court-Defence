# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  name       :string(255)
#  court_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :court do
    sequence(:code) { |n| "#{('A'..'Z').to_a.sample(3).join}-#{n}" }
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    court_type 'crown'
  end
end
