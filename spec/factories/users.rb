# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  persona_id             :integer
#  persona_type           :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  unlock_token           :string
#  settings               :text
#  deleted_at             :datetime
#  api_key                :uuid
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'testing12345' }
    password_confirmation { 'testing12345' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    api_key { SecureRandom.uuid }

    trait :with_settings do
      settings { { setting1: 'test1', setting2: 'test2' }.to_json }
    end

    trait :softly_deleted do
      deleted_at { 10.minutes.ago }
    end

    trait :disabled do
      disabled_at { 10.minutes.ago }
    end

    trait :enabled do
      disabled_at { nil }
    end

    trait :active do
      deleted_at { false }
    end
  end
end
