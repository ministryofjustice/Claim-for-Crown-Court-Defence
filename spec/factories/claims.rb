FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence_class 'A'

    factory :submitted_claim do
      state 'submitted'
      submitted_at { Time.now }
    end
  end
end
