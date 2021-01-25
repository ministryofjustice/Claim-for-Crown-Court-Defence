## Document Storage

CCCD uses Active storage in three models:

* `Document`: Evidence documents for claims. Two files are stored; the original
  uploaded document (`document`) and a version converted to PDF for previews
  (`converted_preview_document`).
* `Message`: An optional document attached to a message on a claim
  (`attachment`).
* `Stats::StatsReport`: A generated CSV MI report (`document`).

Each of these three cases is dealt with slightly differently.

### `Document#document` and `Document#converted_preview_document`

Evidence documents for claims are uploaded during the claim creation process.
They are uploaded individually via the documents controller
(`DocumentsController#create`), which returns the document id and filename,
to allow the form to attach the document to the claim and give feedback to the
user. The document is saved as the `document` attachment.

When a document is uploaded it is immediately converted to PDF (if necessary)
and saved as a second attachment `converted_preview_document`. This conversion
is done by the `convert_document_to_pdf` method in the `DocumentAttachment`
concern. Note that this is currently done using undocumented features (see
comments in the code) as Active Storage does not provice access to the file
before the model `commit`. This can probably be done better as a background
job.

The document may be viewed in the browser with `DocumentController#show` or
downloaded with `DocumentController#download`. Each of these actions redirects
the user's browser to an expiring link in S3 for the PDF preview or the
original document respectively.

#### Changes from Paperclip

##### Returned data from the controller

The return payload from `DocumentController#create` is now created by:

```ruby
{ document: { id: @document.id, document_file_name: @document.document.filename } }
```

and so only returns the id and filename of the document. The key
`document_file_name` is used to provide consistency with the data as it was
returned by Paperclip but this could be changed to something more suitable if
the front-end is updated.

When Paperclip was used the return payload would return all model details with:

```ruby
{ document: @document.reload }
```

This provides more information but most is not used.

##### Document validation

With Paperclip, in addition to converting the document to PDF, the `Document`
model had a `save_and_verify` method that saved the instance and then
re-downloaded the file to make sure that it had been saved correctly. This is
no longer being done for Active Storage.

##### Document view and download

The `show` and `download` actions of the document controller redirect the
users' browser to an S3 link. With Paperclip, these methods in the controller
would download the document to the server and then relay it to the user. This
extra step was deemed to be unecessary.

Active Storage does provide routes for redirecting to download links for files
and these can be generated with the helpers `rails_blob_path` and
`rails_blob_url`. However, these routes are unauthenticated and fixed (although
they are obfuscated) so it was thought better to implement our own routes that
can be authenticated.

### `Message#attachment`

Messages added to a claim may optionally have a single document attached. These
are uploaded with the same form submission as the rest of the message.

As with `Document` (above), the `download_attachment` method of the messages
controller redirects the user to an expiring link to the file in S3.

### `Stats::StatsReport#document`

Stats reports are created by `Stats::StatsReportGenerator` as follows;

* A `Stats::StatsReport` instance is created with no document attached
* The report is generated using the apropriate generator:
  * `ManagementInformationGenerator`
  * `ProvisionalAssessmentReportGenerator`
  * `RejectionsRefusalsReportGenerator`
* The report is attached to the instance using
  `report_record.write_report(report_contents)`

As with `Document` and `Message`, the reports are downloaded with custom routes
instead of the default ones provided by Active Storage so that they can be
authenticated.
