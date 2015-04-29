FactoryGirl.define do
  factory :offence do
    offence_class { OffenceClass.first || create(:offence_class) }
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
