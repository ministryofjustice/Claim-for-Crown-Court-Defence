FactoryGirl.define do
  factory :message do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    claim

    after(:build) do |message|
      message.sender_id = create(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password').id
    end
  end
end
