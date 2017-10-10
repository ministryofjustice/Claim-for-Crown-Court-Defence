# Advocate Defence Payments
###a.k.a Claim for crown court defence

[![Build Status](https://travis-ci.org/ministryofjustice/Claim-for-Crown-Court-Defence.svg?branch=master)](https://travis-ci.org/ministryofjustice/Claim-for-Crown-Court-Defence)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/ministryofjustice/Claim-for-Crown-Court-Defence.svg)](https://gemnasium.com/github.com/ministryofjustice/Claim-for-Crown-Court-Defence)

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

Put the following environment variables into your `.env.development` and `.env.test` files

```
SUPERADMIN_USERNAME='superadmin@example.com'
SUPERADMIN_PASSWORD='whichever'
ADVOCATE_PASSWORD='whatever'
CASE_WORKER_PASSWORD='whatever'
ADMIN_PASSWORD='whatever'
TEST_CHAMBER_API_KEY='--create your own uuid e.g. SecureRandom.uuid--'
GRAPE_SWAGGER_ROOT_URL='http://localhost:3001'
```

Setup dummy users and data:

```
rake db:drop db:create db:reload
```

Run the application (see note below on architecture for the reason why you need to run two servers).

```
rails server
rails server -p 3001 -P /tmp/rails3001.pid
```

To import JSON claims, or import via the API, you need to run a multi-threaded server like unicorn on port 3000.  This can be done with the following line, but the BetterErrors page will not work correctly if you get an exceptions.

```
rails server -e devunicorn
```


## Architecture

This app was originally written as a single monolithic application, with the ability to import claims 
via a public API, or JSON uploads (AGFS claims only).  A decision was later taken to split the Caseworker 
off into a separate application, using the API to communicate to the main app.  This has only partially been 
done.  The CaseWorker allocation pages use the API to talk to the main application, rather than access the 
database directly.  In the dev environment, it accesses another server running on port 3001, which is why you
need to start up the second server.



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

```bash
$ ./script/db_dump.rb <ssh-username> <environment> [<ip_address>]
```

The ```environment``` parameter can be ```gamma```, ```staging```, ```dev```, ```demo```, etc.  The IP address is only required if there is no entry for ```environment``` in your ```/etc/hosts``` file.



This will create a file in the root directory, e.g ```adp_gamma_dump.psql.gz```

To restore this file to one of the other environments, type:

```bash
$ ./script/db_upload.rb <ssh-name> <environment> [<ip_address>] filename
```

In this case, ```environment``` CANNOT be gamma.


To load the database dump on to your local database, use:

```bash
$ rake db:restore[dump-file]
```

Snippet for local dump and restore:

```bash
$ cd <cccd_root>
$ ./script/db_dump.rb <sshusername> gamma <IP|knownhost>
$ rake db:restore['adp_gamma_dump.psql.gz']
$ rm adp_gamma_dump.psql
```

## VAT

The rules for when and when not to apply VAT are rather complex, so are summarised here:

### AGFS

The claim's external_user attribute is an ExternalUser with a role of 'advocate' and has a vat_registered attribute which governs whether or not VAT is applied to fees and expenses.

If true, VAT at the prevailing rate is automatically added to fees and expenses; if false, not VAT is added.

## LGFS

The claim's provider has an attribute 'vat_registered' which governs whether or not VAT is applied.  In this case, VAT is automatically applied to fees.

For both VAT registered and unregistered LGFS providers, a VAT amoutn field is provided for manual input of VAT

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
