FactoryGirl.define do
  factory :document do
    document { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
    document_type
    claim
    notes { Faker::Lorem.sentence }
  end
end
