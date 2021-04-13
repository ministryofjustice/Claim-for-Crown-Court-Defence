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

    after(:create) do |doc|
      # The tests very often check to see if the converted preview doc exists before
      # it has been created, so here we just wait until it has been created up to a maximum of 1 second
      5.times do
        break if File.exist?(doc.converted_preview_document.path)
        sleep 0.2
      end
    end

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
  end
end
