FactoryGirl.define do
  factory :court do
    sequence(:code) { |n| "#{('A'..'Z').to_a.sample(3).join}-#{n}" }
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    court_type 'crown'
  end
end
