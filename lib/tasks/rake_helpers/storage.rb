module Storage
  ATTACHMENTS = {
    'stats_reports' => ['document'],
    'messages' => ['attachment'],
    'documents' => ['document', 'converted_preview_document']
  }.freeze

  def self.migrate(model)
    connection = ActiveRecord::Base.connection.raw_connection
    ATTACHMENTS[model].each do |name|
      # Insert reference information for attachments into ActiveStorage::Blob
      # Set the asset key correctly in ActiveStorage::Blob
      key = self.s3_path_pattern(model).split('/')
        .map do |part|
          case part
          when ':id_partition'
            "TO_CHAR(id, 'fm000/000/000/')"
          when ':filename'
            "#{name}_file_name"
          else
            "'#{part}/'"
          end
        end.join(', ')

      connection.prepare("create_active_storage_blobs_#{name}", <<~SQL)
        INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
          SELECT CONCAT(#{key}),
                 #{name}_file_name,
                 #{name}_content_type,
                 CONCAT('in-progress/', CAST(id AS CHARACTER VARYING)),
                 #{name}_file_size,
                 as_#{name}_checksum,
                 #{name}_updated_at
            FROM #{model}
            WHERE #{name}_file_name IS NOT NULL
              AND id NOT IN (
                SELECT DISTINCT record_id FROM active_storage_attachments
                  WHERE record_type = '#{self.models(model)}'
                    AND name = '#{name}'
              )
          #{self.conflict_clause_for(model)};
      SQL

      # Link ActiveStorage::Blob objects to the correct records with ActiveStorage::Attachment
      connection.prepare("create_active_storage_attachments_#{name}", <<~SQL)
        INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
          SELECT '#{name}',
                 '#{self.models(model)}',
                 CAST(SPLIT_PART(metadata, '/', 2) AS INTEGER),
                 id,
                 created_at
          FROM active_storage_blobs
          WHERE metadata LIKE 'in-progress/%';
      SQL

      connection.prepare("update_active_storage_blobs_metadata_#{name}", <<~SQL)
        UPDATE active_storage_blobs SET metadata='{}' WHERE metadata LIKE 'in-progress/%';
      SQL

      puts "Creating Active Storage Blobs for #{name}"
      connection.exec_prepared("create_active_storage_blobs_#{name}");
      puts "Creating Active Storage Attachments for #{name}"
      connection.exec_prepared("create_active_storage_attachments_#{name}");
      puts "Updating Active Storage blobs metadata for #{name}"
      connection.exec_prepared("update_active_storage_blobs_metadata_#{name}");
    end
  end

  def self.rollback(model)
    connection = ActiveRecord::Base.connection.raw_connection
    ATTACHMENTS[model].each do |name|
      # Delete active storage attachments for the model
      connection.prepare("delete_active_storage_attachments_#{name}", <<~SQL)
        DELETE FROM active_storage_attachments WHERE record_type='#{self.models(model)}' AND name='#{name}'
      SQL

      connection.exec_prepared("delete_active_storage_attachments_#{name}");
    end

    # Delete blobs no longer linked to an attachment
    connection.prepare("delete_active_storage_blobs", <<~SQL)
      DELETE FROM active_storage_blobs
        WHERE id NOT IN (SELECT blob_id FROM active_storage_attachments)
    SQL
    connection.exec_prepared("delete_active_storage_blobs");
  end

  def self.clear_paperclip_checksums(model)
    connection = ActiveRecord::Base.connection.raw_connection
    ATTACHMENTS[model].each do |name|
      # Clear checksums
      connection.prepare("clear_paperclip_checksums_#{name}", <<~SQL)
        UPDATE #{model} SET as_#{name}_checksum=NULL
        WHERE as_#{name}_checksum IS NOT NULL
      SQL

      result = connection.exec_prepared("clear_paperclip_checksums_#{name}")
      puts "Updated #{result.cmd_tuples.to_s.green} rows"
    end
  end

  def self.create_dummy_paperclip_files_for(model)
    if self.models(model).nil?
      puts "Cannot create dummy files for: #{model}"
      exit
    end

    ATTACHMENTS[model].each do |attachment|
      if model.eql?('documents')
        records = DummyDocument.where.not("#{attachment}_file_name" => nil)
      else
        records = self.models(model).where.not("#{attachment}_file_name" => nil)
      end

      bar = self.progress_bar title: attachment, total: records.count

      records.each do |record|
        bar.increment

        next if record.send(attachment).exists?

        filename = if paperclip_storage.eql?(:s3)
                     File.join('tmp', record.send(attachment).path)
                   else
                     File.absolute_path(record.send(attachment).path)
                   end

        create_or_update_dummy_file(record: record, doc_attribute: attachment, filename: filename)
      end
    end
  end

  def self.paperclip_storage
    PAPERCLIP_STORAGE_OPTIONS[:storage]
  end

  def self.create_or_update_dummy_file(record:, doc_attribute:, filename:)
    FileUtils.mkdir_p File.dirname(filename)
    File.open(filename, 'wb') { |file| file.write(SecureRandom.random_bytes(record.send("#{doc_attribute}_file_size"))) }
    file = File.open(filename)

    record.send("#{doc_attribute}=", file)
    record.save(validate: false)
  rescue StandardError => err
    LogStuff.warn(
      module: self.name,
      action: "#{__method__} for #{record.class.table_name}",
      error: "#{err.class} - #{err.message}"
    ) { err.message }
  ensure
    file.close if file
  end

  # Deleting filesystem/s3 files
  # doc.document.destroy will delete the doc and its meta data in the doc model (not want we want)
  # doc.document.clear wil delete the paperclip attachment file, without changing the meta data, unless you save
  # the model object immediatley afterwards.

  # NOTE: for the Document model the `doc.document.clear` message removes the "folder" (tested locally)
  # which includes the converted_preview_document object too. However, calling `.clear` on a non-existant
  # attachment does not raise an error.
  #
  def self.clear_dummy_paperclip_files_for(model)
    if self.models(model).nil?
      puts "Cannot clear dummy files for: #{model}"
      exit
    end

    ATTACHMENTS[model].each do |attachment|
      records = self.models(model).where.not("#{attachment}_file_name" => nil)

      bar = self.progress_bar title: attachment, total: records.count

      records.each do |record|
        bar.increment
        record.send(attachment).clear
        record.send(attachment).save

        # IMPORTANT: do not save the record itself or it will clear meta data
        record.update_column("as_#{attachment}_checksum", nil)
      end
    end
  end

  def self.set_paperclip_checksums(relation:)
    bar = self.progress_bar title: relation.table_name, total: relation.count

    relation.each do |record|
      bar.increment
      record.populate_checksum
      record.save
    end
  end

  def self.progress_bar(title:, total:)
    ProgressBar.create(
      title: title,
      format: "%a [%e] %b\u{15E7}%i %c/%C",
      progress_mark: '#'.green,
      remainder_mark: "\u{FF65}".yellow,
      starting_at: 0,
      total: total
    )
  end

  def self.status(model)
    checksum_formats = { good: [0], bad: (1..) }

    puts model.titlecase
    puts "="*model.length

    all = self.models(model).all
    puts "Total records:      #{all.count.to_s.green}"

    case model
    when 'stats_reports'
      sr_unique = all.distinct.count(:document_file_name)
      puts "Total unique files: #{sr_unique.to_s.green}"
      puts "Missing checksums:  #{self.highlight(all.where(as_document_checksum: nil).count, **checksum_formats)}"
      as = ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport')
      puts "AS records:         #{self.highlight(as.count, bad: (0..sr_unique-1), good: [sr_unique], warning: (sr_unique+1..))}"
      puts "AS records checked: #{self.validate(attachments: as)}"
    when 'messages'
      ms_attachments = all.where.not(attachment_file_name: nil)
      ms_attachments_count = ms_attachments.count
      puts "Total attachments:  #{ms_attachments_count.to_s.green}"
      puts "Missing checksums:  #{self.highlight(ms_attachments.where(as_attachment_checksum: nil).count, **checksum_formats)}"
      as = ActiveStorage::Attachment.where(record_type: 'Message')
      puts "AS records:         #{self.highlight(as.count, bad: (0..ms_attachments_count-1), good: [ms_attachments_count], warning: (ms_attachments_count+1..))}"
      puts "AS records checked: #{self.validate(attachments: as)}"
    when 'documents'
      ds_count = all.count
      migrated_formats = { bad: (0..ds_count-1), good: [ds_count], warning: (ds_count+1..) }
      puts 'Missing checksums'
      puts "  Document:         #{self.highlight(all.where(as_document_checksum: nil).count, **checksum_formats)}"
      puts "  Preview:          #{self.highlight(all.where(as_converted_preview_document_checksum: nil).count, **checksum_formats)}"
      as_doc = ActiveStorage::Attachment.where(record_type: 'Document', name: 'document')
      as_preview = ActiveStorage::Attachment.where(record_type: 'Document', name: 'converted_preview_document')
      puts 'AS records'
      puts "  Document:         #{self.highlight(as_doc.count, **migrated_formats)}"
      puts "  Document checked: #{self.validate(attachments: as_doc)}"
      puts "  Preview:          #{self.highlight(as_preview.count, **migrated_formats)}"
      puts "  Preview checked:  #{self.validate(attachments: as_preview)}"
    end
  end

  private

  def self.models(model)
    {
      'stats_reports' => Stats::StatsReport,
      'messages' => Message,
      'documents' => Document
    }[model]
  end

  def self.s3_path_pattern(model)
    {
      'stats_reports' => REPORTS_STORAGE_OPTIONS[:path],
      'messages' => PAPERCLIP_STORAGE_OPTIONS[:path],
      'documents' => PAPERCLIP_STORAGE_OPTIONS[:path]
    }[model]
  end

  def self.conflict_clause_for(model)
    return 'ON CONFLICT (key) DO UPDATE SET metadata=EXCLUDED.metadata' if model == 'documents'

    'ON CONFLICT DO NOTHING'
  end

  def self.highlight(n, good: nil, warning: nil, bad: nil)
    return n.to_s.green if good&.include? n
    return n.to_s.yellow if warning&.include? n
    return n.to_s.red if bad&.include? n

    n.to_s
  end

  def self.validate(attachments:)
    attachments.each_with_object(true) do |attachment, check|
      check &&
        attachment.blob.filename == attachment.record.send("#{attachment.name}_file_name") &&
        attachment.blob.checksum == attachment.record.send("as_#{attachment.name}_checksum")
    end ? 'OK'.green : 'Failed'.red
  end
end
