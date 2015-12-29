# == Schema Information
#
# Table name: case_workers
#
#  id             :integer          not null, primary key
#  role           :string
#  created_at     :datetime
#  updated_at     :datetime
#  location_id    :integer
#  days_worked    :string
#

FactoryGirl.define do
  factory :case_worker do
    days_worked    [ 1, 1, 1, 1, 1 ]

    after(:build) do |case_worker|
      case_worker.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: 'password', password_confirmation: 'password')
      case_worker.user.email = "#{case_worker.first_name}.#{case_worker.last_name}@laa.gov.uk"
    end

    location

    role 'case_worker'

    trait :admin do
      role 'admin'
    end
  end
end
