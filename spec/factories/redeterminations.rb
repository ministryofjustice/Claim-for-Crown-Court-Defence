FactoryGirl.define do
  factory :redetermination do
    claim         { FactoryGirl.create :claim }
    fees          { Random.rand(500.0).round(2) }
    expenses      { Random.rand(500.0).round(2) }
    disbursements { Random.rand(500.0).round(2) }
  end
end
