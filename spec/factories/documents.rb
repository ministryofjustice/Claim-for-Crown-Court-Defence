FactoryGirl.define do
  factory :document do
    document { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
    document_type
    claim
    advocate
    notes { Faker::Lorem.sentence }

    trait :docx do
      document { File.open(Rails.root + 'features/examples/shorter_lorem.docx')}
      document_content_type { 'application/msword' }
    end

  end
end
