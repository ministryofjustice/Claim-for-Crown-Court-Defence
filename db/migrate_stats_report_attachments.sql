BEGIN;

-- Copy original documents for the Stats::statsReport model into ActiveStorage::Blob
-- Set key to a temporary value for use later
-- TODO: Fix this so that file names are unique (because apparently report filenames
--       can be duplicates and this causes the last statement, below, to fail)
INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
  SELECT CONCAT('in-progress/document/', CAST(id AS CHARACTER VARYING)),
         document_file_name,
         document_content_type,
         '{}',
         document_file_size,
         'chksum',
         document_updated_at
    FROM stats_reports
    WHERE document_file_name IS NOT NULL;

-- Create ActiveStorage::Attachment records for all the new ActiveStorage::Blob records
-- Use the temporary value of the key to set the correct name and Stats::StatsReport id
INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
  SELECT 'document',
         'Stats::StatsReport',
         CAST(SPLIT_PART(key, '/', 3) AS INTEGER),
         id,
         created_at
  FROM active_storage_blobs
  WHERE key LIKE 'in-progress/%';

-- This will change the temporary key to the correct key in the format 'reports/:filename'
-- This is correct for stats reports in development and production
UPDATE active_storage_blobs
  SET key=CONCAT('reports/', filename)
  WHERE key LIKE 'in-progress/%';

ROLLBACK;
-- COMMIT;