# == Schema Information
#
# Table name: supplier_numbers
#
#  id              :integer          not null, primary key
#  provider_id     :integer
#  supplier_number :string
#

FactoryBot.define do
  factory :supplier_number do
    provider
    postcode { Faker::Address.postcode }
    supplier_number { [rand(0..9), ('A'..'Z').to_a[rand(0..25)], rand(100..999), ('A'..'Z').to_a[rand(0..25)]].join }
  end
end
