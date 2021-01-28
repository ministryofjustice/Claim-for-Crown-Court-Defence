require 'tasks/rake_helpers/storage.rb'

namespace :storage do
  desc 'Migrate storage from Paperclip to Active Storage'
  task migrate_paperclip_to_active_storage: :environment do
    class TempMessage < ApplicationRecord
      include S3Headers
      self.table_name = 'messages'
      has_attached_file :attachment, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    module TempStats
      class StatsReport < ApplicationRecord
        include S3Headers
        self.table_name = 'stats_reports'
        has_attached_file :document, s3_headers.merge(REPORTS_STORAGE_OPTIONS)
      end
    end

    class TempDocument < ApplicationRecord
      include S3Headers
      self.table_name = 'documents'
      has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
      has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    storage = Storage.new

    storage.migrate(
      names: ['attachment'],
      model: 'Message',
      records: TempMessage.where.not(attachment_file_name: nil),
      updated_at_field: :updated_at
    )

    storage.migrate(
      names: ['document'],
      model: 'Stats::StatsReport',
      records: TempStats::StatsReport.where.not(document_file_name: nil),
      updated_at_field: :document_updated_at
    )

    storage.migrate(
      names: ['document', 'converted_preview_document'],
      model: 'Document',
      records: TempDocument.all,
      updated_at_field: :updated_at
    )
  end

  desc 'Create some dummy files for testing (assumes local storage)'
  task dummy_files: :environment do
    Message.where.not(attachment_file_name: nil).each do |message|
      filename = File.absolute_path(message.attachment.path)
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'wb') do |file|
        file.write(SecureRandom.random_bytes(message.attachment_file_size))
      end
    end

    Stats::StatsReport.where.not(document_file_name: nil).each do |report|
      filename = File.absolute_path(report.document.path)
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'wb') do |file|
        file.write(SecureRandom.random_bytes(report.document_file_size))
      end
    end

    Document.where.not(document_file_name: nil).each do |document|
      filename = File.absolute_path(document.document.path)
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'wb') do |file|
        file.write(SecureRandom.random_bytes(document.document_file_size))
      end
    end
  end
end