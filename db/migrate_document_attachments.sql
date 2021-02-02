BEGIN;

-- Copy original documents for the Document model into ActiveStorage::Blob
-- Set key to a temporary value for use later
INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
  SELECT CONCAT('in-progress/document/', CAST(id AS CHARACTER VARYING)),
         document_file_name,
         document_content_type,
         '{}',
         document_file_size,
         'chksum',
         updated_at
    FROM documents;

-- Copy converted preview documents for the Document model into ActiveStorage::Blob
-- Skip any documents that are identical to the original document
-- Set key to a temporary value for use later
INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
  SELECT CONCAT('in-progress/converted_preview_document/', CAST(id AS CHARACTER VARYING)),
         converted_preview_document_file_name,
         converted_preview_document_content_type,
         '{}',
         converted_preview_document_file_size,
         'chksum',
         updated_at
    FROM documents
    WHERE document_file_name != converted_preview_document_file_name;

-- Create ActiveStorage::Attachment records for all the new ActiveStorage::Blob records
-- Use the temporary value of the key to set the correct name and Document id
INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
  SELECT SPLIT_PART(key, '/', 2),
         'Document',
         CAST(SPLIT_PART(key, '/', 3) AS INTEGER),
         id,
         created_at
  FROM active_storage_blobs
  WHERE key LIKE 'in-progress/%';

-- This will change the temporary key to the correct key in the format 'documents/:id_partition/:filename'
-- This is correct for documents in production
-- Documents in the development environment need to be 'public/assets/dev/images/docs/:id_partition/:filename'
UPDATE active_storage_blobs
  SET key=CONCAT(
    'documents/', -- 'public/assets/dev/images/docs/' for the development environment
    TO_CHAR(CAST(SPLIT_PART(key, '/', 3) AS INTEGER), 'fm000/000/000/'),
    filename
  )
  WHERE key LIKE 'in-progress/%';

ROLLBACK;
-- COMMIT;