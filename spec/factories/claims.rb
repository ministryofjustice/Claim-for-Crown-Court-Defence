FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence
    documents { example_document }
    advocate_category 'qc_alone'
    sequence(:indictment_number) { |n| "12345-#{n}" }
    prosecuting_authority 'cps'

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
  puts "*" *20
  puts "called #example_document"
  puts "*" *20
  file = File.open('./features/examples/shorter_lorem.docx')
  doc = Document.new(claim_id: 1, document_type_id: 1)
  doc.document = file
  puts "*" *20
  puts doc.document_type
  puts "*" *20
  [doc]
end
