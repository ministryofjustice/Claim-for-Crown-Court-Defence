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
          ON CONFLICT (key) DO UPDATE SET metadata=EXCLUDED.metadata;
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
      SQL

      connection.exec_prepared("clear_paperclip_checksums_#{name}");
    end
  end

  def self.make_dummy_files_for(model)
    if self.models(model).nil?
      puts "Cannot create dummy files for: #{model}"
      exit
    end

    ATTACHMENTS[model].each do |name|
      records = self.models(model).where.not("#{name}_file_name" => nil)

      bar = self.progress_bar title: name, total: records.count

      records.each do |record|
        bar.increment
        filename = File.absolute_path(record.send(name).path)
        FileUtils.mkdir_p File.dirname(filename)
        File.open(filename, 'wb') { |file| file.write(SecureRandom.random_bytes(record.send("#{name}_file_size"))) }
      end
    end
  end

  def self.set_paperclip_checksums(records:, model:)
    bar = self.progress_bar title: ATTACHMENTS[model].join(', '), total: records.count

    records.each do |record|
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

  def self.highlight(n, good: nil, warning: nil, bad: nil)
    return n.to_s.green if good&.include? n
    return n.to_s.yellow if warning&.include? n
    return n.to_s.red if bad&.include? n

    n.to_s
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
end
