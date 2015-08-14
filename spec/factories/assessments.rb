FactoryGirl.define do
  factory :assessment do
    claim         { FactoryGirl.create :claim, :without_assessment }
    fees          250.33
    expenses      845.89
  end
end