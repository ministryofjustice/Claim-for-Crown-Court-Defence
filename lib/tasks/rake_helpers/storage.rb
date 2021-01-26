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

  def migrate names:, model:, records:
    puts model.green
    records.each do |record|
      puts "  #{record.id}".green
      names.each do |name|
        print  "    - #{name}"
        if ActiveStorage::Attachment.find_by(name: name, record_type: model, record_id: record.id)
          puts ' [EXISTS]'.yellow
          next
        end

        Document.transaction do
          attachment = record.send(name)

          blob = ActiveStorage::Blob.find_by(key: attachment.path)
          if blob.nil?
            @connection.exec_prepared(
              'active_storage_blob_statement',
              [
                attachment.path,
                record.send("#{name}_file_name"),
                record.send("#{name}_content_type"),
                record.send("#{name}_file_size"),
                compute_checksum_in_chunks(Paperclip.io_adapters.for(attachment)),
                record.updated_at.iso8601
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
              record.updated_at.iso8601
            ]
          )
          puts ' [CREATED]'.green
        end
      end
    end
  end

  private

  # Copied from https://github.com/rails/rails/blob/main/activestorage/app/models/active_storage/blob.rb
  def compute_checksum_in_chunks(io)
    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(5.megabytes)
        checksum << chunk
      end

      io.rewind
    end.base64digest
  end
end