FactoryGirl.define do
  factory :advocate do
    after(:build) do |advocate|
      advocate.user ||= build(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    chamber { Chamber.find(rand(1..2)) }
  end
end
