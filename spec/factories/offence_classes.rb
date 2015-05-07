FactoryGirl.define do
  factory :offence_class do
    sequence(:class_letter) { ('A'..'K').to_a.sample(1).join }
    description { Faker::Lorem.sentence }
  end
end
