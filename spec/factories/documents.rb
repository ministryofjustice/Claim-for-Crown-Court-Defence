# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  document_type_id                        :integer
#  notes                                   :text
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string(255)
#  document_content_type                   :string(255)
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  advocate_id                             :integer
#  converted_preview_document_file_name    :string(255)
#  converted_preview_document_content_type :string(255)
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#

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

    trait :representation_order do
      document_type          { DocumentType.find_by(description: 'Representation Order') || FactoryGirl.create(:document_type, :representation_order) }
    end

    trait :invoice do
      document_type          { DocumentType.find_by(description: 'Invoice') || FactoryGirl.create(:document_type, :invoice) }
    end

    trait :indictment do
      document_type           { DocumentType.find_by(description: 'Indictment') || FactoryGirl.create(:document_type, :indictment) }
    end

  end


end
