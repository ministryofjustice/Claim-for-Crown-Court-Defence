# Advocate Defence Payments
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

AWS S3 the **default** document storage mechanism. It is stubbed out
using webmock for all tests, but active in development mode.

```
adp_aws_access_key    = <AWS access key>  # Required
adp_secret_access_key = <AWS secret key>  # Required
adp_bucket_name       = <AWS bucket name> # Optional
```

The bucket name will default to `moj_cbo_documents_#{Rails.env}` if
`adp_bucket_name` is not set.

## Setting up development environment

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

To ping all environments
```
alias ping.adp='for i in dev-adp.dsd.io staging-adp.dsd.io demo-adp.dsd.io api-sandbox-adp.dsd.io claim-crown-court-defence.service.gov.uk ; do a="https://${i}/ping.json" ; echo $a; b=`curl --silent $a` ; echo $b; echo; done'
```

To run unit and integration tests in parallel
```
alias rake.fast='rake parallel:spec; rake parallel:features'
```

## Sidekiq Console

To display the current state of the Sidekiq queues, as a logged in superadmin browse to `/sidekiq`

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Anonymised Database Dumps/restores

In order to copy the live database, anonymising all entries, execute the following command:

```
./script/db_dump <ssh-username> <environment> [<ip_address>]
```

The ```environment``` parameter can be ```gamma```, ```staging```, ```dev```, ```demo```, etc.  The IP address is only required if there is no entry for ```environment``` in your ```/etc/hosts``` file.



This will create a file in the root directory, e.g ```adp_gamma_dump.psql.gz```

To restore this file to one of the other environments, type:

```
./script/db_upload.rb <ssh-name> <environment> [<ip_address>] filename
```

In this case, ```environment``` CANNOT be gamma.


To load the database dump on to your local database, use:

```
rake db:restore[dump-file]
```




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
