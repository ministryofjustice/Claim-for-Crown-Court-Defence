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
#

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'testing123'
    password_confirmation 'testing123'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :with_settings do
      settings { {setting1: 'test1', setting2: 'test2'}.to_json }
    end
  end
end
