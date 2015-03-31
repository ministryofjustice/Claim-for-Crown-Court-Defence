FactoryGirl.define do
  factory :document do
    claim
    description 'Document description'
    document 'sample.docx'
  end
end
