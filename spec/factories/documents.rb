FactoryGirl.define do
  factory :document do
    document { fixture_file_upload(Rails.root + 'features/examples/shorter_lorem.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', :binary) }
  end
end
