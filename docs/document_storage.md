## Document Storage

CCCD uses Active storage in three models:

* `Document`: Evidence documents for claims. Two files are stored; the original
  uploaded document (`document`) and a version converted to PDF for previews
  (`converted_preview_document`).
* `Message`: An optional document attached to a message on a claim
  (`attachment`).
* `Stats::StatsReport`: A generated CSV MI report (`document`).

Each of these three cases is dealt with slightly differently.

### `Stats::StatsReport#document`

Stats reports are created by `Stats::StatsReportGenerator` as follows;

* A `Stats::StatsReport` instance is created with no document attached
* The report is generated using the apropriate generator:
  * `ManagementInformationGenerator`
  * `ProvisionalAssessmentReportGenerator`
  * `RejectionsRefusalsReportGenerator`
* The report is attached to the instance using
  `report_record.write_report(report_contents)`

The reports are downloaded with custom routes instead of the default ones
provided by Active Storage so that they can be authenticated. These routes are:

* `caseworkers/admin/management_information/download?report_type=management_information`
* `caseworkers/admin/management_information/download?report_type=provisional_assessment`
* `caseworkers/admin/management_information/download?report_type=rejections_refusals`

### `Message#attachment`

Messages added to a claim may optionally have a single document attached. These
are uploaded with the same form submission as the rest of the message.

As with `Stats::StatsReports` (above), the `download_attachment` method of the
messages controller redirects the user to an expiring link to the file in S3.
The route for this download is:

* `/messages/:id/download_attachment`

where `:id` is the id of the message.

### `Document#document` and `Document#converted_preview_document`

To do