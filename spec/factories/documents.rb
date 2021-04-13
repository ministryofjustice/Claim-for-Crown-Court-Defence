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
    document do
      Rack::Test::UploadedFile.new(
        File.expand_path('features/examples/longer_lorem.pdf', Rails.root),
        'application/pdf'
      )
    end
    claim
    external_user

    trait :pdf # default

    trait :docx do
      document do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/shorter_lorem.docx', Rails.root),
          'application/msword'
        )
      end
    end

    trait :with_preview do
      document do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/shorter_lorem.docx', Rails.root),
          'application/msword'
        )
      end
      converted_preview_document do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/longer_lorem.pdf', Rails.root),
          'application/pdf'
        )
      end
    end

    trait :unverified do
      verified_file_size { 0 }
      verified { false }
    end

    trait :verified do
      verified_file_size { 2663 }
      document do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/longer_lorem.pdf', Rails.root),
          'application/pdf'
        )
      end
      verified { true }
    end

    trait :empty do
      document { nil }
      verified_file_size { 0 }
      verified { false }
    end
  end
end
