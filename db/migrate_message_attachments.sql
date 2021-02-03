BEGIN;

-- Copy original documents for the Message model into ActiveStorage::Blob
-- Set key to a temporary value for use later
INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
  SELECT CONCAT('in-progress/attachment/', CAST(id AS CHARACTER VARYING)),
         attachment_file_name,
         attachment_content_type,
         '{}',
         attachment_file_size,
         'chksum',
         updated_at
    FROM messages
    WHERE attachment_file_name IS NOT NULL;

-- Create ActiveStorage::Attachment records for all the new ActiveStorage::Blob records
-- Use the temporary value of the key to set the correct name and Message id
INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
  SELECT 'attachment',
         'Message',
         CAST(SPLIT_PART(key, '/', 3) AS INTEGER),
         id,
         created_at
  FROM active_storage_blobs
  WHERE key LIKE 'in-progress/%';

-- This will change the temporary key to the correct key in the format 'documents/:id_partition/:filename'
-- This is correct for messages in production
-- Messages in the development environment need to be 'public/assets/dev/images/docs/:id_partition/:filename'
UPDATE active_storage_blobs
  SET key=CONCAT(
    'documents/', -- 'public/assets/dev/images/docs/' for the development environment
    TO_CHAR(CAST(SPLIT_PART(key, '/', 3) AS INTEGER), 'fm000/000/000/'),
    filename
  )
  WHERE key LIKE 'in-progress/%';

ROLLBACK;
-- COMMIT;