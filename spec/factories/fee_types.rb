# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :fee_type do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    fee_category
  end
end
