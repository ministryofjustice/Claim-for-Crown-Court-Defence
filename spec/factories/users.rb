FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'testing123'
    password_confirmation 'testing123'
  end
end
