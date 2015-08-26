# == Schema Information
#
# Table name: chambers
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  supplier_number :string(255)
#  vat_registered  :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#

FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:supplier_number) { |n| "#{n}-#{Time.now.to_i}" }
  end
end
