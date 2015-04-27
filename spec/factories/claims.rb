FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence
    documents { example_document }

    factory :invalid_claim do
      case_type 'invalid case type'
    end

    factory :submitted_claim do
      state 'submitted'
      submitted_at { Time.now }
    end

    factory :completed_claim do
      state 'completed'
      submitted_at { Time.now }
    end
  end

end

def example_document
  file = File.open('./features/examples/shorter_lorem.docx')
  doc = Document.new(claim_id: 1, document_type_id: 1)
  doc.document = file
  doc.document_content_type = 'application/msword'
  [doc]
end
