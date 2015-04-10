FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'testing123'
    password_confirmation 'testing123'

    factory :advocate do
      role 'advocate'
    end

    factory :case_worker do
      role 'case_worker'
    end

    factory :admin do
      role 'admin'
    end
  end
end
