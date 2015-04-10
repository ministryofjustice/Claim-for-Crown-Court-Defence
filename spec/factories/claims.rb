FactoryGirl.define do
  factory :claim do
    court
    advocate
    case_type 'trial'
    offence_class 'A'
  end
end
