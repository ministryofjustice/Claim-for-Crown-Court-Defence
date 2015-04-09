FactoryGirl.define do
  factory :claim do
    court
    advocate
    case_type 'trial'
  end
end
