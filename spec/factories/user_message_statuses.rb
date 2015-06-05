FactoryGirl.define do
  factory :user_message_status do
    user
    message
    read false

    trait :read do
      read true
    end
  end
end
