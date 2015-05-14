FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence
    advocate_category 'qc_alone'
    sequence(:indictment_number) { |n| "12345-#{n}" }
    prosecuting_authority 'cps'

    factory :invalid_claim do
      case_type 'invalid case type'
    end

    factory :submitted_claim do
      after(:create) { |claim| claim.submit! }
    end

    factory :allocated_claim do
      after(:create) { |claim| claim.submit! }
      after(:create) { |claim| claim.allocate! }
    end

    factory :completed_claim do
      after(:create) { |claim| claim.submit! }
      after(:create) { |claim| claim.allocate! }
      after(:create) { |claim| claim.pay! }
      after(:create) { |claim| claim.complete! }
    end
  end

end
