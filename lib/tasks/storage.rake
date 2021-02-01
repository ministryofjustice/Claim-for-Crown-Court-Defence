require 'tasks/rake_helpers/storage.rb'

namespace :storage do
  desc 'Migrate stats reports from Paperclip to Active Storage'
  task migrate_stats_reports: :environment do
    module TempStats
      class StatsReport < ApplicationRecord
        include S3Headers
        self.table_name = 'stats_reports'
        has_attached_file :document, s3_headers.merge(REPORTS_STORAGE_OPTIONS)
      end
    end

    Storage.new.migrate(
      names: ['document'],
      model: 'Stats::StatsReport',
      records: TempStats::StatsReport.where.not(document_file_name: nil),
      updated_at_field: :document_updated_at
    )
  end

  desc 'Migrate messages from Paperclip to Active Storage'
  task migrate_messages: :environment do
    class TempMessage < ApplicationRecord
      include S3Headers
      self.table_name = 'messages'
      has_attached_file :attachment, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    Storage.new.migrate(
      names: ['attachment'],
      model: 'Message',
      records: TempMessage.where.not(attachment_file_name: nil),
      updated_at_field: :updated_at
    )
  end

  desc 'Migrate documents from Paperclip to Active Storage'
  task migrate_documents: :environment do
    class TempDocument < ApplicationRecord
      include S3Headers
      self.table_name = 'documents'
      has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
      has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    Storage.new.migrate(
      names: ['document', 'converted_preview_document'],
      model: 'Document',
      records: TempDocument.all,
      updated_at_field: :updated_at
    )
  end

  desc 'Create dummy stats report files (assumes local storage)'
  task dummy_stats_reports: :environment do
    reports = Stats::StatsReport.where.not(document_file_name: nil)
    
    Storage.new.make_dummy_files reports, 'document'
  end

  desc 'Create dummy message files (assumes local storage)'
  task dummy_messages: :environment do
    messages = Message.where.not(attachment_file_name: nil)
    
    Storage.new.make_dummy_files messages, 'attachment'
  end

  desc 'Create dummy document files (assumes local storage)'
  task dummy_documents: :environment do
    documents = Document.where.not(document_file_name: nil)
    
    storage = Storage.new
    storage.make_dummy_files documents, 'document'
    storage.make_dummy_files documents, 'converted_preview_document'
  end
end