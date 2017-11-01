# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  court_type :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :court do
    sequence(:code) { |n| "#{('A'..'Z').to_a.sample(3).join}-#{n}" }
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    court_type 'crown'
  end
end
