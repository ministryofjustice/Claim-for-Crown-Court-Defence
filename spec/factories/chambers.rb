# == Schema Information
#
# Table name: chambers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  vat_registered  :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  api_key         :uuid
#

FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:supplier_number) { |n| "#{n}-#{Time.now.to_i}" }
  end
end
