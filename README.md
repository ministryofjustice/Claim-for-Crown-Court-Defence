# Advocate Defence Payments

[![Build Status](https://travis-ci.org/ministryofjustice/advocate-defence-payments.svg)](https://travis-ci.org/ministryofjustice/advocate-defence-payments)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)

## Development and Demo Currently Sync with Heroku

Both run in `production` mode and a push will only happen if
[Travis](https://travis-ci.org/ministryofjustice/crime-billing-online)
passes.

In order to deploy, just push your passing changes to the `develop`
branch. It is served from
[http://crime-billing-online-dev.herokuapp.com/](http://crime-billing-online-dev.herokuapp.com/). This push is triggered from travis and the details can be found in `travis.yml`.  The db is cleared each time and migrations and seeding occur automatically.

The `master` branch is served from
[http://crime-billing-online.herokuapp.com/](http://crime-billing-online.herokuapp.com/) and tracks github. This is triggered from heroku. See the `Deploy` tab in the heroku web console. The db is maintained between pushes.  New migrations will have to be manually run using the heroku toolbelt.



## S3 for document storage

AWS S3 the **default** docuemnt storage mechanism. It is stubbed out
using webmock for all tests, but active in development mode.

```
adp_aws_access_key    = <AWS access key>  # Required
adp_secret_access_key = <AWS secret key>  # Required
adp_bucket_name       = <AWS bucket name> # Optional
```

The bucket name will default to `moj_cbo_documents_#{Rails.env}` if
`adp_bucket_name` is not set.


