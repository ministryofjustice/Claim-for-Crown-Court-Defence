# == Schema Information
#
# Table name: case_workers
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :case_worker do
    after(:build) do |case_worker|
      case_worker.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    role 'case_worker'

    trait :admin do
      role 'admin'
    end
  end
end
