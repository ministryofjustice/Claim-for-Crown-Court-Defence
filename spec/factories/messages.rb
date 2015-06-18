# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  subject    :string(255)
#  body       :text
#  claim_id   :integer
#  sender_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :message do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    claim

    after(:build) do |message|
      message.sender_id = create(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password').id
    end
  end

  factory :unpersisted_message, class: Message do
    subject         { Faker::Lorem.sentence }
    body            { Faker::Lorem.paragraph }
    claim           { FactoryGirl.build :unpersisted_claim }
    sender          { FactoryGirl.build :user }
  end
end
