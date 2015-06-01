# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :document_type do
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
