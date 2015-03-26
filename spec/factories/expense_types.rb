FactoryGirl.define do
  factory :expense_type do
    name { Faker::Lorem.word }
  end
end
