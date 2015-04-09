# Crime Billing Online

[![Build Status](https://travis-ci.org/ministryofjustice/crime-billing-online.svg)](https://travis-ci.org/ministryofjustice/crime-billing-online)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)

## Development currently syncs with Heroku

This occurs only if
[Travis](https://travis-ci.org/ministryofjustice/crime-billing-online)
passes.

In order to deploy, just push your passing changes to the `develop`
branch.

## S3 for document storage

AWS S3 the **default** docuemnt storage mechanism for production mode.  To enable it
for use in any other mode, set the following environment variables:

```
cbo_use_s3            = true              # Activates S3 for selected mode.
cbo_aws_access_key    = <AWS access key>  # Required
cbo_secret_access_key = <AWS secret key>  # Required
cbo_bucket_name       = <AWS bucket name> # Optional
```

The bucket name will default to `moj_cbo_documents_#{Rails.env}` if
`cbo_bucket_name` is not set.

