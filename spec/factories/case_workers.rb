# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
#  deleted_at  :datetime
#  uuid        :uuid
#

FactoryBot.define do
  factory :case_worker do
    transient do
      build_user { true }
    end

    after(:build) do |case_worker, evaluator|
      if evaluator.build_user
        case_worker.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: 'password1234', password_confirmation: 'password1234')
        case_worker.user.email = "#{case_worker.first_name}.#{case_worker.last_name}@laa.gov.uk"
      end
    end

    location

    roles { ['case_worker'] }

    trait :case_worker do
      roles { ['case_worker'] }
    end

    trait :admin do
      roles { ['admin'] }
    end

    trait :provider_manager do
      roles { ['provider_management'] }
    end

    trait :softly_deleted do
      deleted_at { 10.minutes.ago }
    end
  end
end
