# Advocate Defence Payments

## changes to readme to force travis to run


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
Setup dummy users and data:

```
CASE_WORKER_PASSWORD='12345678' ADMIN_PASSWORD='12345678' ADVOCATE_PASSWORD='12345678' rake db:drop db:create db:migrate db:seed claims:demo_data[1,1]
```
Run the application:

```
rails server
```
