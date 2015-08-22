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
#  uuid           :uuid
#

FactoryGirl.define do
  factory :advocate do
    after(:build) do |advocate|
      advocate.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    chamber
    account_number  { generate_unique_account_number }


    role 'advocate'

    trait :admin do
      role 'admin'
    end
  end
end


def generate_unique_account_number
  alpha_part = ""
  2.times{alpha_part  << (65 + rand(25)).chr}
  numeric_part = rand(999)
  "#{alpha_part}#{sprintf('%03d', numeric_part)}"
end
