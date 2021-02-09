module Storage
  ATTACHMENTS = {
    'stats_reports' => ['document'],
    'messages' => ['attachment'],
    'documents' => ['document', 'converted_preview_document']
  }.freeze

  def self.migrate model
    connection = ActiveRecord::Base.connection.raw_connection
    ATTACHMENTS[model].each do |name|
      # Insert reference information for attachments into ActiveStorage::Blob
      connection.prepare('create_active_storage_blobs', <<~SQL)
        INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
          SELECT CONCAT('in-progress/', CAST(id AS CHARACTER VARYING)),
                #{name}_file_name,
                #{name}_content_type,
                '{}',
                #{name}_file_size,
                as_#{name}_checksum,
                #{name}_updated_at
            FROM #{self.models(model).table_name}
            WHERE #{name}_file_name IS NOT NULL
              AND id NOT IN (SELECT DISTINCT record_id FROM active_storage_attachments WHERE record_type = '#{self.models(model)}');
      SQL

      # Link ActiveStorage::Blob objects to the correct records with ActiveStorage::Attachment
      connection.prepare('create_active_storage_attachments', <<~SQL)
        INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
          SELECT '#{name}',
                 '#{self.models(model)}',
                 CAST(SPLIT_PART(key, '/', 2) AS INTEGER),
                 id,
                 created_at
          FROM active_storage_blobs
          WHERE key LIKE 'in-progress/%';
      SQL

      # Set the asset key correctly in ActiveStorage::Blob
      key = PAPERCLIP_STORAGE_OPTIONS[:path].split('/')
        .map do |part|
          case part
          when ':id_partition'
            "TO_CHAR(CAST(SPLIT_PART(key, '/', 2) AS INTEGER), 'fm000/000/000/')"
          when ':filename'
            "filename"
          else
            "'#{part}/'"
          end
        end.join(', ')
      connection.prepare('update_active_storage_blobs_keys', <<~SQL)
        UPDATE active_storage_blobs SET key=CONCAT(#{key}) WHERE key LIKE 'in-progress/%';
      SQL

      connection.exec_prepared('create_active_storage_blobs');
      connection.exec_prepared('create_active_storage_attachments');
      connection.exec_prepared('update_active_storage_blobs_keys');
    end
  end

  def self.make_dummy_files_for model
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

  def self.set_checksums(records:, model:)
    bar = self.progress_bar title: ATTACHMENTS[model].join(', '), total: records.count

    records.each do |record|
      bar.increment
      ATTACHMENTS[model].each do |name|
        record.update("as_#{name}_checksum": self.compute_checksum_in_chunks(record.send(name)))
      end
    end
  end

  # Copied from https://github.com/rails/rails/blob/main/activestorage/app/models/active_storage/blob.rb
  def self.compute_checksum_in_chunks(attachment)
    io = Paperclip.io_adapters.for(attachment)

    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(5.megabytes)
        checksum << chunk
      end

      io.rewind
    end.base64digest
  rescue Errno::ENOENT
    'FileMissing'
  rescue Errno::ENAMETOOLONG
    'FilenameTooLong'
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

  private

  def self.models model
    {
      'stats_reports' => Stats::StatsReport,
      'messages' => Message,
      'documents' => Document
    }[model]  
  end
end