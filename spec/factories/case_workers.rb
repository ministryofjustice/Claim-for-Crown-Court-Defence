FactoryGirl.define do
  factory :case_worker do
    after(:build) do |case_worker|
      case_worker.user ||= build(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    role 'case_worker'

    factory :admin do
      role 'admin'
    end
  end
end
