FactoryGirl.define do
  factory :claim do
    court
    advocate
    case_type 'trial'
    offence_class 'A'

    factory :invalid_claim do
      case_type 'invalid case type'
    end

  end
end
