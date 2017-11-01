# == Schema Information
#
# Table name: user_message_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message_id :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :user_message_status do
    user
    message
    read false

    trait :read do
      read true
    end

    trait :unpersisted do
      user            { FactoryBot.build :user }
      message         { FactoryBot.build :unpersisted_message }
    end
  end
end
