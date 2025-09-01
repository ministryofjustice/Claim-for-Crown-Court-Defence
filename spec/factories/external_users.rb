# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#  vat_registered  :boolean          default(TRUE)
#  provider_id     :integer
#  roles           :string
#  deleted_at      :datetime
#

FactoryBot.define do
  factory :external_user do
    transient do
      build_user { true }
    end

    after(:build) do |eu, evaluator|
      if evaluator.build_user
        eu.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.unique.email, password: 'PasswordForTest', password_confirmation: 'PasswordForTest')
      end
    end

    provider
    roles { ['advocate'] }
    supplier_number { generate_unique_supplier_number }

    trait :advocate do
      roles { ['advocate'] }
      provider { association :provider, :agfs }
    end

    trait :litigator do
      roles { ['litigator'] }
      supplier_number { nil }
      provider { association :provider, :lgfs }
    end

    trait :advocate_litigator do
      roles { %w[advocate litigator] }
      provider { association :provider, :agfs_lgfs }
    end

    trait :admin do
      roles { ['admin'] }
      supplier_number { nil }
    end

    trait :advocate_and_admin do
      roles { %w[admin advocate] }
    end

    trait :litigator_and_admin do
      supplier_number { nil }
      roles { %w[litigator admin] }
      provider { association :provider, :lgfs }
    end

    trait :agfs_lgfs_admin do
      roles { ['admin'] }
      provider { association :provider, :agfs_lgfs }
    end

    trait :softly_deleted do
      deleted_at { 10.minutes.ago }
    end

    trait :disabled do
      after(:create) do |eu|
        eu.user.update(disabled_at: 10.minutes.ago)
      end
    end
  end
end

def generate_unique_supplier_number
  alpha_part = ''
  2.times { alpha_part << rand(65..89).chr }
  numeric_part = rand(999)
  "#{alpha_part}#{format('%03d', numeric_part)}"
end
