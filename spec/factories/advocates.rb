# == Schema Information
#
# Table name: advocates
#
#  id             :integer          not null, primary key
#  role           :string(255)
#  chamber_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  account_number :string(255)
#

FactoryGirl.define do
  factory :advocate do
    after(:build) do |advocate|
      advocate.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    chamber
    sequence(:account_number, 100) { |n| "AC#{n}" }


    role 'advocate'

    trait :admin do
      role 'admin'
    end
  end
end
