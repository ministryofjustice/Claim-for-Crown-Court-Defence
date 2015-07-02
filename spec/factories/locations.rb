FactoryGirl.define do
  factory :location do
    name { Faker::Address.city }
  end
end
