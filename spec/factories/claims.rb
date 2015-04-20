FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence_class 'A'

    factory :invalid_claim do
      case_type 'invalid case type'
    end

    factory :submitted_claim do
      state 'submitted'
      submitted_at { Time.now }
    end

    factory :completed_claim do
      state 'completed'
      submitted_at { Time.now }
    end
  end
end
