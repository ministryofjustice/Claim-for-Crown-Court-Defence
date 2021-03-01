require 'tasks/rake_helpers/storage.rb'

namespace :storage do
  desc 'Migrate assets from Paperclip to Active Storage'
  task :migrate, [:model] => :environment do |_task, args|
    Storage.migrate args[:model]
  end

  desc 'Rollback asset migration'
  task :rollback, [:model] => :environment do |_task, args|
    Storage.rollback args[:model]
  end

  desc 'Create dummy assets files'
  task :dummy_files, [:model] => :environment do |_task, args|
    production_protected

    Storage.make_dummy_files_for args[:model]
  end

  desc 'Add file checksums to paperclip columns'
  task :add_paperclip_checksums, [:model] => :environment do |_task, args|
    module TempStats
      class StatsReport < ApplicationRecord
        include S3Headers
        include CheckSummable

        self.table_name = 'stats_reports'
        has_attached_file :document, s3_headers.merge(REPORTS_STORAGE_OPTIONS)

        def populate_checksum
          add_checksum(:document) unless document_file_name.nil?
        end
      end
    end

    class TempMessage < ApplicationRecord
      include S3Headers
      include CheckSummable

      self.table_name = 'messages'
      has_attached_file :attachment, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

      def populate_checksum
        add_checksum(:attachment) unless attachment_file_name.nil?
      end
    end

    class TempDocument < ApplicationRecord
      include S3Headers
      include CheckSummable

      self.table_name = 'documents'
      has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
      has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

      def populate_checksum
        add_checksum(:document) unless document_file_name.nil?
        add_checksum(:converted_preview_document) unless converted_preview_document.nil?
      end
    end

    case args[:model]
    when 'stats_reports'
      records = TempStats::StatsReport.where.not(document_file_name: nil).where(as_document_checksum: nil)
    when 'messages'
      records = TempMessage.where.not(attachment_file_name: nil).where(as_attachment_checksum: nil)
    when 'documents'
      records = TempDocument.where(as_document_checksum: nil)
    else
      puts "Cannot calculate checksums for: #{args[:model]}"
      exit
    end

    puts "Setting checksums for #{args[:model].green}"
    Storage.set_paperclip_checksums(records: records, model: args[:model])
  end

  desc 'Clear temporary paperclip checksums for specified model'
  task :clear_paperclip_checksums, [:model] => :environment do |_task, args|
    Storage.clear_paperclip_checksums args[:model]
  end

  desc 'Show status of storage migration'
  task status: :environment do
    checksum_formats = { good: [0], bad: (1..) }

    puts 'Stats Reports'
    puts '============='
    sr = Stats::StatsReport.all
    puts "Total records:      #{sr.count.to_s.green}"
    sr_unique = sr.distinct.count(:document_file_name)
    puts "Total unique files: #{sr_unique.to_s.green}"
    puts "Missing checksums:  #{Storage.highlight(sr.where(as_document_checksum: nil).count, **checksum_formats)}"
    as = ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport')
    puts "AS records:         #{Storage.highlight(as.count, bad: (0..sr_unique-1), good: [sr_unique], warning: (sr_unique+1..))}"

    puts
    puts 'Messages'
    puts '========'
    ms = Message.all
    puts "Total records:      #{ms.count.to_s.green}"
    ms_attachments = ms.where.not(attachment_file_name: nil)
    ms_attachments_count = ms_attachments.count
    puts "Total attachments:  #{ms_attachments_count.to_s.green}"
    puts "Missing checksums:  #{Storage.highlight(ms_attachments.where(as_attachment_checksum: nil).count, **checksum_formats)}"
    as = ActiveStorage::Attachment.where(record_type: 'Message')
    puts "AS records:         #{Storage.highlight(as.count, bad: (0..ms_attachments_count-1), good: [ms_attachments_count], warning: (ms_attachments_count+1..))}"

    puts
    puts 'Documents'
    puts '========='
    ds = Document.all
    puts "Total records:      #{ds.count.to_s.green}"
    ds_count = ds.count
    migrated_formats = { bad: (0..ds_count-1), good: [ds_count], warning: (ds_count+1..) }
    puts "Missing checksums"
    puts "  Document:         #{Storage.highlight(ds.where(as_document_checksum: nil).count, **checksum_formats)}"
    puts "  Preview:          #{Storage.highlight(ds.where(as_converted_preview_document_checksum: nil).count, **checksum_formats)}"
    as_doc = ActiveStorage::Attachment.where(record_type: 'Document', name: 'document')
    as_preview = ActiveStorage::Attachment.where(record_type: 'Document', name: 'converted_preview_document')
    puts "AS records"
    puts "  Document:         #{Storage.highlight(as_doc.count, **migrated_formats)}"
    puts "  Preview:          #{Storage.highlight(as_preview.count, **migrated_formats)}"
  end
end
