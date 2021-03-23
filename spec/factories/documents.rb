# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string
#  document_content_type                   :string
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  external_user_id                        :integer
#  converted_preview_document_file_name    :string
#  converted_preview_document_content_type :string
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#  form_id                                 :string
#  creator_id                              :integer
#  verified_file_size                      :integer
#  file_path                               :string
#  verified                                :boolean          default(FALSE)
#

FactoryBot.define do
  factory :document do
    document { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
    claim
    external_user

    trait :docx do
      document { File.open(Rails.root + 'features/examples/shorter_lorem.docx') }
      document_content_type { 'application/msword' }
    end

    trait :unverified do
      verified_file_size { 0 }
      verified { false }
    end

    trait :verified do
      verified_file_size { 2663 }
      file_path { Rails.root + 'features/examples/longer_lorem.pdf' }
      verified { true }
    end

    trait :empty do
      document { nil }
      verified_file_size { 0 }
      verified { false }
    end

    trait :pdf # Default

    trait :with_preview do
      document { File.open(Rails.root + 'features/examples/longer_lorem.png') }
      document_content_type { 'image/png' }
      converted_preview_document { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
      converted_preview_document_content_type { 'application/pdf' }
    end
  end
end
