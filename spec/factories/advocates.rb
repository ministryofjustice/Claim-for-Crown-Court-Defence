FactoryGirl.define do
  factory :advocate do
    after(:build) do |advocate|
      advocate.user ||= build(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    chamber
  end
end
