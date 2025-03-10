# Active Storage migration plan

## Contents

* [Overview](#Overview)
* [Stats Reports](#Stats-Reports)
* [Messages](#Messages)
* [Documents](#Documents)
* [Switchover](#Switchover)
* [Switchover rollback](#Switchover-rollback)
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
   Active Storage and is time consuming to generate. However, it can be done in
   advance of the migration to avoid disruption.
2) Test that checksums have been created correctly.
3) Copy information in the database about the assets from where Paperclip has
   them to where they need to be for Active Storage.
4) Test that document information has been copied correctly.
5) Update the application to use Active Storage to create and access assets.
6) Test that existing assets can be accessed and new assets can be created.

The current status of the storage migration can be seen using the
`storage:status` task:

```bash
$ bundle exec rails storage:status
Stats Reports
=============
Total records:      58
Total unique files: 42
Missing checksums:  58
AS records:         0
AS records checked: OK
(etc)
```

## Stats Reports

The 'Stats Reports' section of the `storage:status` task output contains:

```bash
Total records:      58  <-- Total number of stats reports records. Each record
                            includes a Paperclip attachment, although some
                            files are attached to multiple records.
Total unique files: 42  <-- Total number excluding duplicate Paperclip
                            attachments.
Missing checksums:  58  <-- Number of records without a checksum. On completion
                            this should be zero.
AS records:         0   <-- Number of Active Storage attachments for stats
                            reports. On completion this should be the same as
                            the total number of stats reports records excluding
                            duplicates.
AS records checked: OK  <-- Check that each Active Storage record is linked to
                            the same file and has the same checksum as the
                            corresponding Paperclip attachment.
```

1) Generate checksums:

```bash
$ bundle exec rails 'storage:add_paperclip_checksums[stats_reports]'
```

2) Ensure that the checksums have been created correctly using the
`storage:status` task (see above). The `Missing checksum` count should be zero.

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[stats_reports]'
```

4) Confirm that all records have been migrated using the `storage:status` task
(see above). The `AS records` count should be the same as the `Total unique
files` count and `AS records checked` should be `OK`.

5) Test that a sample document can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Stats::StatsReport').sample.url
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

> **_IMPORTANT:_** This rollback section relates to cleaning up migrated data and should NOT be used to rollback the application to using paperclip after switching over to active storage. To rollback to using paperclip see [Switchover rollback](#switchover-rollback)

**Note:** This rollback should not be attempted after [CBO-1683](https://dsdmoj.atlassian.net/browse/CBO-1683) has been completed

* To roll back the migration of assets from Paperclip to Active Storage use the
  `storage:rollback` task. This will delete records from the
  `active_storage_attachments` and `active_storage_blobs` tables.

```bash
$ bundle exec rails 'storage:rollback[stats_reports]'
```

* To delete checksums that have been calculated prior to migration use the
  `storage:clear_paperclip_checksums` task.

```bash
$ bundle exec rails 'storage:clear_paperclip_checksums[stats_reports]'
```

## Messages

The 'Messages' section of the `storage:status` task output contains:

```bash
Total records:      117587  <-- Total number of messages records. Each message
                                record has an optional Paperclip attachment.
Total attachments:  20715   <-- Total number of message records that have a
                                Paperclip attachment.
Missing checksums:  20715   <-- Number of records with Paperclip attachments
                                without a checksum. On completion this should
                                be zero.
AS records:         0       <-- Number of Active Storage attachments for
                                messages. On completion this should be the same
                                as the total number of Paperclip attachments.
AS records checked: OK      <-- Check that each Active Storage record for
                                messages is linked to the same for and has the
                                same checksum as the corresponding Paperclip
                                attachment.
```

1) Generate checksums:

```bash
$ bundle exec rails 'storage:add_paperclip_checksums[messages]'
```

2) Ensure that the checksums have been created correctly using the
`storage:status` task (see above). The `Missing checksum` count should be zero.

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[messages]'
```

4) Confirm that all records have been migrated using the `storage:status` task
(see above). The `AS records` count should be the same as the `Total
attachments` count and `AS records checked` should be `OK`.

5) Test that a sample message attachment can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample attachment
rails> ActiveStorage::Attachment.where(record_type: 'Message').sample.url
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

> **_IMPORTANT:_** This rollback section relates to cleaning up migrated data and should NOT be used to rollback the application to using paperclip after switching over to active storage. To rollback to using paperclip see [Switchover rollback](#switchover-rollback)

**Note:** This rollback should not be attempted after [CBO-1692](https://dsdmoj.atlassian.net/browse/CBO-1692) has been completed.

* To roll back the migration of assets from Paperclip to Active Storage use the
  `storage:rollback` task. This will delete records from the
  `active_storage_attachments` and `active_storage_blobs` tables.

```bash
$ bundle exec rails 'storage:rollback[messages]'
```

* To delete checksums that have been calculated prior to migration use the
  `storage:clear_paperclip_checksums` task.

```bash
$ bundle exec rails 'storage:clear_paperclip_checksums[messages]'
```

## Documents


The 'Documents' section of the `storage:status` task output contains:

```
Total records:      204432 <-- Total number of document records. Each document
                               includes two Paperclip attachments, for the
                               original document and the converted preview. If
                               the original document is a PDF then both
                               Paperclip attachments will link to the same
                               file.
Missing checksums
  Document:         204432 <-- Number of document records for which the
                               checksum for the original document is missing.
                               On completion this should be zero.
  Preview:          204432 <-- Number of document records for which the
                               checksum for the converted preview is missing.
                               On completion this should be zero.
AS records
  Document:         0      <-- Number of Active Storage attachments for the
                               original documents. On completion this should be
                               the same as the total number of document
                               records.
  Document checked: OK     <-- Check that each Active Storage record for the
                               original documents is linked to the same file
                               and has the same checksum as the corresponding
                               Paperclip attachment.
  Preview:          0      <-- Number of Active Storage attachments for the
                               converted previews. On completion this should be
                               the same as the total number of document
                               records.
  Preview checked:  OK     <-- Check that each Active Storage record for the
                               converted previews is linked to the same file
                               and has the same checksum as the corresponding
                               Paperclip attachment.
```

1) Generate checksums:

```bash
$ bundle exec rails 'storage:add_paperclip_checksums[documents]'
```

2) Ensure that the checksums have been created correctly using the
`storage:status` task (see above). The `Missing checksum` count for both
document and preview should be zero.

3) Migrate assets details from Paperclip to Active Storage:

```bash
$ bundle exec rails 'storage:migrate[documents]'
```

4) Confirm that all records have been migrated using the `storage:status` task
(see above). The `AS records` count should be the same as the `Total records`
count for `Document` and `Preview`, and `Document checked` and `Preview
checked` should both be `OK`.

5) Test that a sample document can be downloaded via Active Storage (this will only work when S3 is used for storage):

```ruby
# Get a download url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Document', name: 'document').sample.url
# => "https://cloud-platform-..."
# Paste this url into a browser and confirm that it can be downloaded

# Get a download preview url for a sample document
rails> ActiveStorage::Attachment.where(record_type: 'Document', name: 'converted_preview_document').sample.url(disposition: 'inline')
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

> **_IMPORTANT:_** This rollback section relates to cleaning up migrated data and should NOT be used to rollback the application to using paperclip after switching over to active storage. To rollback to using paperclip see [Switchover rollback](#switchover-rollback)

* To roll back the migration of assets from Paperclip to Active Storage use the
  `storage:rollback` task. This will delete records from the
  `active_storage_attachments` and `active_storage_blobs` tables.

```bash
$ bundle exec rails 'storage:rollback[documents]'
```

* To delete checksums that have been calculated prior to migration use the
  `storage:clear_paperclip_checksums` task.

```bash
$ bundle exec rails 'storage:clear_paperclip_checksums[documents]'
```

## Redrafting bug

There is a bug with the redrafting of claims that may be related to how
documents are stored in Paperclip. See
[CBO-1233,](https://dsdmoj.atlassian.net/browse/CBO-1233)
[CBO-1393](https://dsdmoj.atlassian.net/browse/CBO-1393) and
[CBO-1679.](https://dsdmoj.atlassian.net/browse/CBO-1569) After the Active
Storage migration is complete this last ticket needs to be reviewed to see if
the issue has been resolved. This can be done by checking for redraft failures
due to timeouts in Kibana logs, for example.

## Switchover

> **_NOTE:_** This switchover from paperclip to active storage assumes that checksums have been calculated for the model being activated and the target environment has latest main on it - with the `storage.rake` tasks is available on it.

---
**Summary**
  - migrate
  - deploy activating branch *
  - migrate
---

  - merge the activating branch \*. Ensure you use a merge commit as this can be easily reverted if necessary.
  - wait for CircleCI to have successfully built main and be waiting for approval to deploy to the target environment
  - migrate phase 1: shell into the target environments worker pod and run rake task to migrate data from paperclip to active storage
    ```
    rails storage:migrate[model_table_name]
    rails storage:status
    ```
  - migrate phase 2: approve deploy of the merged activating branch to the environment and wait for rollout to complete
  - migrate phase 3: shell into target environments worker pod and rerun migration to ensure any records created by users during deploy are migrated
    ```
    rails storage:migrate[model_table_name]
    rails storage:status
    ```

  \* activating branch: the branch that switches on active storage use for the specific model

| model/env | dev-lgfs | dev | staging | api-sandbox | production |
|-|-|-|-|-|-|
| stats_reports | &check; | &check; | &check; | &check; | &check; |
| messages | &check; | &check; | &check; | &check; | &check; |
| documents |  |  |  |  |  |

## Switchover rollback

The code base has been changed to continue to update paperclip fields with the relevant data for accessing files added to the
app by users even after switchover to active storage. This means switching back to using paperclip is purely a matter of
reverting the commit that activated active storage.

 * find the commit
 * revert it
 ```
 git checkout -b revert-to-paperclip-for-stats_reports
 git revert -m 1 <merge-commit-sha-for-stats-report>
 git push -u origin revert-to-paperclip-for-stats_reports
 # raise PR
 ```

> **_NOTE:_** It may be advantageous to prepare such a reverting PR before performing the related switchover in case reversion becomes necessary

## Clean up

After the migration to Active Storage has been completed successfully
Paperclip can be removed.

* Delete s3 dummy files, to save money (see `storage::clear_dummy_paperclip_files`)
* Remove the `paperclip` gem from `Gemfile`
* **[Done]** Delete `lib/tasks/storage.rake` and `lib/tasks/rake_helpers/storage.rb`
* **[Done]** Delete `app/models/dummy_document.rb`
* **[Done]** Delete `app/models/concerns/check_summable.rb` together with all instances
  `include CheckSummable`, `add_checksum` and `calculate_checksum`. Remove
  `spec/models/concern/check_summable_spec.rb`.
* **[Done]** Delete `app/models/concerns/paperclip_rollback.rb` together with all
  instances of `include PaperclipRollback` and `populate_paperclip_for`.
* **[Done]** Remove `PAPERCLIP_STORAGE_OPTIONS`, `REPORTS_STORAGE_OPTIONS` and
  `REPORTS_STORAGE_OPTIONS` from the configuration files in
  `config/environments`.
* **[Done]** Remove `PAPERCLIP_STORAGE_PATH` and `REPORTS_STORAGE_PATH`from the
  configuration files in `config/environments`.
* **[Done]** Remove `kubernetes_deploy/cron_jobs/add_evidence_document_checksums.yml`
* **[Done]** Amend ` kubernetes_deploy/scripts/cronjob.sh` to remove reference to `add_evidence_document_checksums`
* **Note:** This step is destructive and cannot be reverted.
  Remove Paperclip related fields from the database:
  * **[Done]** In `stats_reports`; `document_file_name`, `document_content_type`,
    `document_file_size`, `document_updated_at`, `as_document_checksum`
  * **[Done]** In `messages`; `attachment_file_name`, `attachment_content_type`,
    `attachment_file_size`, `attachment_updated_at`, `as_attachment_checksum`
  * **[Done]** In `documents`; `document_file_name`, `document_content_type`
    `document_file_size`, `document_updated_at`,
    `converted_preview_document_file_name`,
    `converted_preview_document_content_type`
    `converted_preview_document_file_size`,
    `converted_preview_document_updated_at`,
    `as_document_checksum`, `as_converted_preview_document_checksum`
* Remove unneeded (?!check) `documents.file_path` attribute. This was added as a part
  of upload "verification" and should probably have been called `verified_file_path`.
  It holds the full s3 path. It is, nonetheless, unclear why it is needed at all.
* **[Done]** Remove `config/initializers/paperclip.rb`
* **[Done]** Remove `#document#path` and  `#converted_preview_document#path` tests from
  `spec/model/document_spec.rb`
* **[Done]** Remove `#attachment#path` from `spec/model/message_spec.rb`
* **[Done]** Remove `#document#path` from `spec/model/stats/stats_report_spec.rb`
* Ticket to find and remove orphan document, message and stats_reports records
* Ticket to find and remove active storage records with no s3 object associated with them.

