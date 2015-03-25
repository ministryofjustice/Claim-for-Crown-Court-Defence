FactoryGirl.define do
  factory :advocate do
    email { Faker::Internet.email }
    password 'testing123'
    password_confirmation 'testing123'
  end
end
