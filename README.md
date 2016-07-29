# Advocate Defence Payments vvvv
###a.k.a Claim for crown court defence

[![Build Status](https://travis-ci.org/ministryofjustice/advocate-defence-payments.svg)](https://travis-ci.org/ministryofjustice/advocate-defence-payments)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/advocate-defence-payments/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/advocate-defence-payments)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/advocate-defence-payments/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/advocate-defence-payments/coverage)

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

## Developing Cucumber tests

A detailed guide can be found [here](https://github.com/ministryofjustice/advocate-defence-payments/tree/plan-cukes-structure/features#cucumber-test-structure) which sets out the directory structure and expectations on future developed cucumber tests.


## Javascript Unit Testing

Run it using the `guard` command. Jasmine output available here: [http://localhost:8888](http://localhost:8888)


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

## Useful aliases

To ping all enviroments
```
alias ping.adp='for i in dev-adp.dsd.io staging-adp.dsd.io demo-adp.dsd.io api-sandbox-adp.dsd.io claim-crown-court-defence.service.gov.uk ; do a="https://${i}/ping.json" ; echo $a; b=`curl --silent $a` ; echo $b; echo; done'
```

To run unit and integration tests in parrallel
```
alias rake.fast='rake parallel:spec; rake parallel:features'
```

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Contributing

Bug reports and pull requests are welcome.

1. Fork the project (https://github.com/ministryofjustice/advocate-defence-payments/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit until you are happy with your contribution (`git commit -am 'Add some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Make sure your changes are covered by tests, so that we don't break it unintentionally in the future.
6. Create a new pull request.

## License

Released under the [MIT License](http://www.opensource.org/licenses/MIT). Copyright (c) 2015-2016 Ministry of Justice.
