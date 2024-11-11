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
    transient do
      sequence(:filename) { |n| "testfile#{n}.pdf" }
    end

    document do
      Dir.mktmpdir do |tmp|
        temp_file = File.expand_path(filename, tmp)
        FileUtils.cp(File.expand_path('features/examples/longer_lorem.pdf', Rails.root), temp_file)
        Rack::Test::UploadedFile.new(temp_file, 'application/pdf')
      end
    end
    claim
    external_user

    trait :pdf # default

    trait :docx do
      transient do
        sequence(:filename) { |n| "testfile#{n}.docx" }
      end

      document do
        Dir.mktmpdir do |tmp|
          temp_file = File.expand_path(filename, tmp)
          FileUtils.cp(File.expand_path('features/examples/shorter_lorem.docx', Rails.root), temp_file)
          Rack::Test::UploadedFile.new(temp_file, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
        end
      end
    end

    trait :with_preview do
      transient do
        sequence(:filename) { |n| "testfile#{n}.docx" }
      end

      document do
        Dir.mktmpdir do |tmp|
          temp_file = File.expand_path(filename, tmp)
          FileUtils.cp(File.expand_path('features/examples/shorter_lorem.docx', Rails.root), temp_file)
          Rack::Test::UploadedFile.new(temp_file, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
        end
      end

      converted_preview_document do
        Dir.mktmpdir do |tmp|
          temp_file = File.expand_path("#{filename}.pdf", tmp)
          FileUtils.cp(File.expand_path('features/examples/longer_lorem.pdf', Rails.root), temp_file)
          Rack::Test::UploadedFile.new(temp_file, 'application/pdf')
        end
      end
    end

    trait :unverified do
      verified_file_size { 0 }
      verified { false }
    end

    trait :verified do
      verified_file_size { 2663 }
      verified { true }
    end

    trait :empty do
      document { nil }
      verified_file_size { 0 }
      verified { false }
    end
  end
end
