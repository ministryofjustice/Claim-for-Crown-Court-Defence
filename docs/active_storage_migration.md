# Active Storage migration plan

## Contents

* [Overview](#Overview)
* [Stats Reports](#Stats-Reports)
* [Messages](#Messages)
* [Documents](#Documents)
* [Clean up](#Clean-up)

## Overview

These notes outline the plan for migrating CCCD assets from Paperclip to
Active Storage. Assets exist in three different places:

* Stats reports
* Attachments on messages
* Evidence documents

and each of these is dealt with separately. The process is similar for each but
with some small differences and can be summarised as:

1) Generate checksums for all existing assets. The Checksum is required by
   Active Storage and is time consuming. However, it can be done in advance of
   the migration to avoid disruption.
2) Test that checksums have been created correctly.
3) Copy information in the database about the assets from where Paperclip has
   them to where they need to be for Active Storage.
4) Test that document information has been copied correctly.
5) Update the application to use Active Storage to create and access assets.
6) Test that existing assets can be accessed and new assets can be created.

## Stats Reports

1) Generate checksums:

```bash
$ bundle exec rails 'storage:calculate_checksums[stats_reports]'
```

2) Ensure that the checksums have been created correctly:

```ruby
rails> srs = Stats::StatsReport.all

# Total number of stats reports
rails> srs.count

# Number of stats reports with nil checksum
rails> srs.where(as_attachment_checksum: nil).count
# Should be zero

# Number of stats reports with a valid checksum
# A valid checksum ends with '==', such as '4+g5Nmjax5aCg3HtRmCO5Q=='
rails> srs.select { |sr| sr.as_attachment_checksum&.match(/==$/) }.count
# Should be the same as srs.count, above
```

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[stats_reports]'
```

4) Confirm that all reports have been migrated:

```ruby
# List of Paperclip filenames
# Note that there may be duplicate Stats::StatsReport records for the same
# file but the file will only be copied to Active Storage once
rails> pc_filenames = Stats::StatsReport.pluck(:document_file_name).uniq.sort

# List of Active Storage filenames
rails> as_filenames = ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport').map(&:filename).map(&:to_s).sort

rails> pc_filenames == as_filenames
# => true inducates that the migration is successful
# => false indicates that the migraiton has failed
```

5) Test that a sample document can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport').sample.service_url
# => "https://cloud-platform-..."
# Paste this url into a browser and confirm that it can be downloaded
# Note that this url will expire in 5 minutes
```

6) (Final step) Activate Active Storage for stats reports by deploying PR #3722 (CBO-1683)

### Testing

1) After the final step above has been completed the first test is to download
   the reports at `case_workers/admin/management_information` without
   regenerating.
2) Next, regenerate the report and download again. Confirm that the new
   document is different from the previous.

### Rollback

**Note 1:** This rollback should not be attempted after PR #3722 has been deployed
(final step, above) as this will delete assets from Active Storage that do not
exist in Paperclip.

**Note 2:** Using `destroy` or `destroy_all` on `ActiveStorage::Attachment` may
delete the actual files so `delete` is used instead, even though it is more
involved.

1) Get a list of stats reports records in Active Storage:

```ruby
rails> attachments = ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport')
```

2) Record the list of blobs for these attachments:

```ruby
rails> blobs = ActiveStorage::Blob.where(id: attachments.pluck(:blob_id))
```

3) Remove attachment and blob records:

```ruby
rails> attachments.delete_all
rails> blobs.delete_all
```

4) Delete checksums

```ruby
rails> Stats::StatsReport.update_all(as_document_checksum: nil)
```

## Messages

1) Generate checksums:

```bash
$ bundle exec rails 'storage:calculate_checksums[messages]'
```

2) Ensure that the checksums have been created correctly:

```ruby
rails> ms = Message.all

# Total number of messages
rails> ms.count

# Number of messages with nil checksum
rails> ms.where(as_attachment_checksum: nil).count
# Should be zero

# Number of attachments with a valid checksum
# A valid checksum ends with '==', such as '4+g5Nmjax5aCg3HtRmCO5Q=='
rails> ms.select { |m| m.as_attachment_checksum&.match(/==$/) }.count
# Should be the same as ms.count, above
```

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[messages]'
```

4) Confirm that all messages have been migrated:

```ruby
# List of Paperclip filenames
rails> pc_filenames = Message.pluck(:attachment_file_name).sort

# List of Active Storage filenames
rails> as_filenames = ActiveStorage::Attachment.where(record_type: 'Message').map(&:filename).map(&:to_s).sort

rails> pc_filenames == as_filenames
# => true inducates that the migration is successful
# => false indicates that the migraiton has failed
```

5) Test that a sample message attachment can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample attachment
rails> ActiveStorage::Attachment.where(record_type: 'Message').sample.service_url
# => "https://cloud-platform-..."
# Paste this url into a browser and confirm that it can be downloaded
# Note that this url will expire in 5 minutes
```

6) (Final step) Activate Active Storage for stats reports by deploying PR #3735 (CBO-1692)

### Testing

1) Find an existing case with a message attachment. Confirm that the attachment
   can be downloaded correctly.
2) Add a new message to a case and add an attachment. Confirm that the
   attachment can be downloaded correctly.

### Rollback

**Note 1:** This rollback should not be attempted after PR #3735 has been deployed
(final step, above) as this will delete assets from Active Storage that do not
exist in Paperclip.

**Note 2:** Using `destroy` or `destroy_all` on `ActiveStorage::Attachment` may
delete the actual files so `delete` is used instead, even though it is more
involved.

1) Get a list of stats reports records in Active Storage:

```ruby
rails> attachments = ActiveStorage::Attachment.where(record_type: 'Message')
```

2) Record the list of blobs for these attachments:

```ruby
rails> blobs = ActiveStorage::Blob.where(id: attachments.pluck(:blob_id))
```

3) Remove attachment and blob records:

```ruby
rails> attachments.delete_all
rails> blobs.delete_all
```

4) Delete checksums

```ruby
rails> Message.update_all(as_attachment_checksum: nil)
```

## Documents

1) Generate checksums:

```bash
$ bundle exec rails 'storage:calculate_checksums[documents]'
```

2) Ensure that the checksums have been created correctly:

```ruby
rails> ds = Document.all

# Total number of documents
rails> ds.count

# Number of documents with nil checksum
rails> ds.where(as_document_checksum: nil).count
# Should be zero

# Number of preview documents with nil checksum
rails> ds.where(as_converted_preview_document_checksum: nil).count
# Should be zero

# Number of documents with a valid checksum
# A valid checksum ends with '==', such as '4+g5Nmjax5aCg3HtRmCO5Q=='
rails> ds.select { |d| d.as_document_checksum&.match(/==$/) }.count
# Should be the same as ds.count, above

# Number of preview documents with a valid checksum
# A valid checksum ends with '==', such as '4+g5Nmjax5aCg3HtRmCO5Q=='
rails> ds.select { |d| d.as_converted_preview_document_checksum&.match(/==$/) }.count
# Should be the same as ds.count, above
```

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[documents]'
```

4) Confirm that all documents have been migrated:

```ruby
# List of Paperclip filenames for original documents
rails> pc_document_filenames = Message.pluck(:document_file_name).sort

# List of Active Storage filenames for original documents
rails> as_document_filenames = ActiveStorage::Attachment.where(record_type: 'Document', name: 'document').map(&:filename).map(&:to_s).sort

rails> pc_document_filenames == as_document_filenames
# => true inducates that the migration is successful
# => false indicates that the migraiton has failed

# List of Paperclip filenames for preview documents
rails> pc_preview_filenames = Message.pluck(:document_file_name).sort

# List of Active Storage filenames for preview documents
rails> as_preview_filenames = ActiveStorage::Attachment.where(record_type: 'Document', name: 'converted_preview_document').map(&:filename).map(&:to_s).sort

rails> pc_preview_filenames == as_preview_filenames
# => true inducates that the migration is successful
# => false indicates that the migraiton has failed
```

5) Test that a sample document can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Document', name: 'document').sample.service_url
# => "https://cloud-platform-..."
# Paste this url into a browser and confirm that it can be downloaded

# Get a download preview url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Document', name: 'converted_preview_document').sample.service_url(disposition: 'inline')
# => "https://cloud-platform-..."
# Paste this url into a browser and confirm that it can be previewed in the browser

# Note that these url will expire in 5 minutes
```

6) (Final step) Activate Active Storage for documents by deploying PR #3739 (CBO-1693)

### Testing

1) Find an case with a message attachment. Confirm that evidence documents can
   be downloaded and viewed in browser.
2) As a caseworker, confirm that all documents can be downloaded as a zip file.
   can be downloaded correctly.
3) Add a new case and confirm that documents can be accessed as in steps (1)
   and (2)

### Rollback

**Note 1:** This rollback should not be attempted after PR #3739 has been deployed
(final step, above) as this will delete assets from Active Storage that do not
exist in Paperclip.

**Note 2:** Using `destroy` or `destroy_all` on `ActiveStorage::Attachment` may
delete the actual files so `delete` is used instead, even though it is more
involved.

1) Get a list of stats reports records in Active Storage:

```ruby
rails> attachments = ActiveStorage::Attachment.where(record_type: 'Document')
```

2) Record the list of blobs for these attachments:

```ruby
rails> blobs = ActiveStorage::Blob.where(id: attachments.pluck(:blob_id))
```

3) Remove attachment and blob records:

```ruby
rails> attachments.delete_all
rails> blobs.delete_all
```

4) Delete checksums

```ruby
rails> Document.update_all(as_document_checksum: nil, as_converted_preview_document_checksum: nil)
```

## Clean up

After the migration to Active Storage has been completed successfully
Paperclip can be removed.

* Remove the `paperclip` gem from `Gemfile`
* Delete `lib/tasks/storage.rake` and `lib/tasks/rake_helpers/storage.rb`
* Delete `app/models/concerns/check_summable.rb` together with all instances
  `include CheckSummable`, `add_checksum` and `calculate_checksum`
* Remove `PAPERCLIP_STORAGE_OPTIONS`, `REPORTS_STORAGE_OPTIONS` and
  `REPORTS_STORAGE_OPTIONS` from the configuration files in
  `config/environments`.
* **Note:** This step is destructive and cannot be reverted.
  Remove Paperclip related fields from the database:
  * In `stats_reports`; `document_file_name`, `document_content_type`,
    `document_file_size`, `document_updated_at`, `as_document_checksum`
  * In `messages`; `attachment_file_name`, `attachment_content_type`,
    `attachment_file_size`, `attachment_updated_at`, `as_attachment_checksum`
  * In `documents`; `document_file_name`, `document_content_type`
    `document_file_size`, `document_updated_at`,
    `converted_preview_document_file_name`,
    `converted_preview_document_content_type`
    `converted_preview_document_file_size`,
    `converted_preview_document_updated_at`,
    `as_document_checksum`, `as_converted_preview_document_checksum`
