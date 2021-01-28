class Storage
  def initialize
    @connection = ActiveRecord::Base.connection.raw_connection

    @connection.prepare('active_storage_blob_statement', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL
    @connection.prepare('active_storage_attachment_statement', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, $4, $5)
    SQL
  end

  def migrate names:, model:, records:, updated_at_field:
    puts model.green
    bar = ProgressBar.create(
      title: model,
      format: "%a [%e] %b\u{15E7}%i %c/%C",
      progress_mark: '#'.green,
      remainder_mark: "\u{FF65}".yellow,
      starting_at: 0,
      total: records.count
    )
    records.each_with_index do |record, i|
      bar.increment
      names.each do |name|
        next if ActiveStorage::Attachment.find_by(name: name, record_type: model, record_id: record.id)

        ActiveStorage::Attachment.transaction do
          attachment = record.send(name)
          updated_at = record.send(updated_at_field).iso8601

          blob = ActiveStorage::Blob.find_by(key: attachment.path)
          if blob.nil?
            @connection.exec_prepared(
              'active_storage_blob_statement',
              [
                attachment.path,
                record.send("#{name}_file_name"),
                record.send("#{name}_content_type"),
                record.send("#{name}_file_size"),
                compute_checksum_in_chunks(attachment),
                updated_at
              ]
            )

            blob = ActiveStorage::Blob.find_by(key: attachment.path)
          end

          @connection.exec_prepared(
            'active_storage_attachment_statement',
            [
              name,
              model,
              record.id,
              blob.id,
              updated_at
            ]
          )
        end
      end
    end
  end

  private

  # Copied from https://github.com/rails/rails/blob/main/activestorage/app/models/active_storage/blob.rb
  def compute_checksum_in_chunks(attachment)
    io = Paperclip.io_adapters.for(attachment)

    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(5.megabytes)
        checksum << chunk
      end

      io.rewind
    end.base64digest
  rescue Errno::ENOENT
    'FileMissing'
  end
end