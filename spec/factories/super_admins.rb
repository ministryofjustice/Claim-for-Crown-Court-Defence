# == Schema Information
#
# Table name: super_admins
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :super_admin do
    after(:build) do |super_admin|
      super_admin.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end
  end
end
