require 'tasks/rake_helpers/storage.rb'

namespace :storage do
  desc 'Migrate storage from Paperclip to Active Storage'
  task migrate_paperclip_to_active_storage: :environment do
    storage = Storage.new

    storage.migrate(
      names: ['attachment'],
      model: 'Message',
      records: Message.where.not(attachment_file_name: nil)
    )

    storage.migrate(
      names: ['document'],
      model: 'Stats::StatsReport',
      records: Stats::StatsReport.where.not(document_file_name: nil)
    )

    storage.migrate(
      names: ['document', 'converted_preview_document'],
      model: 'Document',
      records: Document.all
    )
  end
end