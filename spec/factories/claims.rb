FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence
    advocate_category 'qc_alone'
    representation_order_date { Time.now.to_date }
    sequence(:indictment_number) { |n| "12345-#{n}" }
    prosecuting_authority 'cps'

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
