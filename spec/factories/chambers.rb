FactoryGirl.define do
  factory :chamber do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:supplier_no) { |n| "123456-#{n}" }
  end
end
