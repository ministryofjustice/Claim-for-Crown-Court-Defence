FactoryGirl.define do
  factory :advocate do
    after(:build) do |advocate|
      advocate.user ||= build(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    chamber
  end
end
