# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
#

FactoryGirl.define do
  factory :case_worker do
    after(:build) do |case_worker|
      case_worker.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: 'password', password_confirmation: 'password')
      case_worker.user.email = "#{case_worker.first_name}.#{case_worker.last_name}@laa.gov.uk"
    end

    location

    roles ['case_worker']

    trait :case_worker do
      roles ['case_worker']
    end

    trait :admin do
      roles ['admin']
    end

    trait :softly_deleted do
      deleted_at 10.minutes.ago
    end
  end
end
