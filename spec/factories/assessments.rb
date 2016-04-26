FactoryGirl.define do
  factory :assessment do
    claim         { FactoryGirl.create :claim, :without_assessment }
    fees          250.33
    expenses      845.89
    disbursements 150.00

    trait :blank do
      fees 0
      expenses 0
      disbursements 0
    end
  end
end