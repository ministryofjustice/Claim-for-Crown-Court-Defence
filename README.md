# Advocate Defence Payments
###a.k.a Claim for crown court defence

[![Build Status](https://travis-ci.org/ministryofjustice/advocate-defence-payments.svg)](https://travis-ci.org/ministryofjustice/advocate-defence-payments)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/crime-billing-online/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/crime-billing-online)

## Staging
[staging-adp.dsd.io](https://staging-adp.dsd.io)

## Demo
[demo-adp.dsd.io](https://demo-adp.dsd.io)

## Dev
[dev-adp.dsd.io](http://dev-adp.dsd.io)

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

## Setting up development enviroment

Install gems

```
bundle install
```

Put the following environment variables into your shell profile

```
export SUPERADMIN_USERNAME='superadmin@example.com'
export SUPERADMIN_PASSWORD='whichever'
export ADVOCATE_PASSWORD='whatever'
export CASE_WORKER_PASSWORD='whatever'
export ADMIN_PASSWORD='whatever'
export TEST_CHAMBER_API_KEY='--create your own uuid--'
export GRAPE_SWAGGER_ROOT_URL='http://localhost:3000'
```

Setup dummy users and data:

```
rake db:drop db:create db:migrate db:seed claims:demo_data
```

Run the application (claim import feature will not work in the default environment):

```
rails server
```

To use the Claim Import feature locally, the devunicorn environment must be used:

```
rails server -e devunicorn
```


## Other useful rake tasks

```
rake db:reseed --clear, migrate, seed
```

```
rake db:reload --clear, migrate, seed, demo data
```

```
rake api:smoke_test  -- test basic API functionality
```

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates
