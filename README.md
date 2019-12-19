# Claim for crown court defence
### a.k.a Advocate Defence Payments, Crime Billing Online

[![CircleCI](https://circleci.com/gh/ministryofjustice/Claim-for-Crown-Court-Defence/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/Claim-for-Crown-Court-Defence/tree/master)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/Claim-for-Crown-Court-Defence/coverage)

## Staging
[staging.claim-crown-court-defence.service.justice.gov.uk](https://staging.claim-crown-court-defence.service.justice.gov.uk)

## Dev
[dev.claim-crown-court-defence.service.justice.gov.uk](http://dev.claim-crown-court-defence.service.justice.gov.uk)

## S3 for document storage

AWS S3, the **default** document storage mechanism, is stubbed out
using webmock for all tests, and set to local storage in development mode.

See `config/aws.yaml` and note that because we use the [config](https://github.com/railsconfig/config) gem, secret settings like `Settings.aws.s3.access` require an envvar `SETTINGS__AWS__S3__ACCESS`.

## Setting up development environment

### Dependencies

* Postgresql
* Redis

```
# for mac osx
brew bundle
```

### Setup

Install gems, set environment files and setup database

```
# From the root of the project
bin/setup
```

**NOTE:** You can change the [default values](.env.sample) for the environment variables as necessary in each of the environment files (e.g. `.env.development` and `.env.test`)

### Setup dummy users and data

```
rake db:drop db:create db:reload
```

### Run the application server

See note below on architecture for the reason why you need to run two servers.

```
rails server
rails server -p 3001 -P /tmp/rails3001.pid
```

You can run a multi-process server like unicorn on port 3000. This can be done with the following line, but the BetterErrors page will not work correctly if you get an exceptions.

```
rails server -e devunicorn
```

### Install wkhtmltopdf

Install [wkhtmltopdf](http://macappstore.org/wkhtmltopdf)
wkhtmltopdf is used to generate PDFs from html templates. You will need to install this locally.

```bash
# for mac osx
brew cask install wkhtmltopdf
```
or
```bash
brew bundle
```

### Install Libreoffice

Libreoffice is used to convert files uploaded in CCCD to PDFs for generating performant, viewable documents of any document type, accessed via a view link. You will need to install this locally.

```bash
# for mac osx
brew cask install libreoffice
```
or
```bash
# for mac osx
brew bundle
```

## Architecture

This app was originally written as a single monolithic application, with the ability to import claims via a public API.  A decision was later taken to split the Caseworker off into a separate application, using the API to communicate to the main app.  This has only partially been
done.

The CaseWorker allocation pages use the API to talk to the main application, rather than access the database directly.  In the local development environment, it accesses another server running on port 3001, which is why you need to start up the second server.

## Testing

To execute unit tests

```
bundle exec rspec
```

To execute cucumber feature tests

```
bundle exec cucumber
```

## Testing external services


#### LAA fee calculator API
##### RSpec
Some rspec unit tests require VCR cassettes for the LAA fee calculator API external service. These specs are tagged with `:fee_calc_vcr` so can be targetted using rspec cmdline options.

```bash
# run specs requiring LAA fee calculator API call stubs/cassettes
$ rspec --tag fee_calc_vcr

```

Changes to the calling of the LAA fee calculator API will most likely require you to rerecord the VCR cassettes that stub these calls. To rerecord VCR cassettes you can delete the existing ones (in `vcr/cassettes/spec`). They will be recreated when the specs are run.

It is a good idea to do this when changes occur to the LAA fee calculator API too.

##### Cucumber
Some cucumber features require VCR cassettes to stub calls to the LAA fee calculator API. These features require and are tagged with a `@fee_calc_vcr` tag. To re-record the cassettes delete the existing ones and run the feature again. See
[Create a new VCR cassette](#create-new-vcr-cassette).

For convenience the VCR recording mode for all cucumber scenarios tagged with `@fee_calc_vcr` can be changed by supplying an enviroment variable from the commandline.

```bash
# delete a bunch of fee calculator features
$ rm -rf vcr/cassettes/features/fee_calculator/

# run applicable features and set recording mode to 'new_episodes' if the scenario is tagged with @fee_calc_vcr
$ FEE_CALC_VCR_MODE=new_episodes cucumber features/fee_calculator/

# or run all those tagged with @fee_calc_vcr
$ FEE_CALC_VCR_MODE=new_episodes cucumber --tag @fee_calc_vcr
```

#### Internal API
Some cucumber feature tests use VCR to record/store mock results the internal API calls (calling our own API) for certain endpoints (case worker claims in particular).
To create a new feature/scenario that relies on such endpoints you will therefore need to record a new "cassette", as below.

##### Create new VCR cassette

Run this in a new console:

```bash
# Start internal API for use by test suite
$ RAILS_ENV=test rails s -p 3001 -P /tmp/rails3001.pid
```

In your `.feature` file add this step before any calls relying on the internal API - i.e. which will be mocked by the cassette produced:

```ruby
# default recording mode has been set to `:once` so it will create a new cassette of the given name if there is not one.
And I insert the VCR cassette 'features/case_workers/claims/injection_error'
```

You can change the default recording mode (:once) by adding `and record 'all|new_episodes|none|once'` to the end of this step
```ruby
# record new vcr episodes. Remember to remove this once they are recorded.
And I insert the VCR cassette 'features/case_workers/claims/injection_error' and record 'new_episodes'
```

Add this step at the point you want to stop recording and write the output to the cassette file:

```ruby
# eject the previously inserted cassette (optional if there already is one but needs to be done if a new is being created in order to output the file
And I eject the VCR cassette
```

Run the feature:
```bash
# note: the 0000.feature is run first to clear the db - not sure if still/always needed
cucumber features/000.feature features/injection_errors.feature
```

After you have run it once you must amend the cassette inserting step as below if you added `and record 'all|new_episodes'` to prevent it creating new cassettes on each run:

```ruby
And I insert the VCR cassette 'features/case_workers/claims/injection_error'
```

You are done. To test terminate/prevent the api service that the test relies on from running - in our example Crtl+c on the console running the rails server on port 3001 - and run the
feature again. It should no longer require the api endpoints.

You should now commit the cassette to the repo to ensure it is not unneccessarily created by upstream test suite runs on the CI solution.

***When you change a feature test such that you need to re-record its cassette you should delete the existing cassette in the `vcr` folder and proceed as if creating a new cassette, above.***


## Maintenance mode

A conditional catchall routes exists in `routes.rb`. This directs all routes requested to the `pages#servicedown` controller and view. To activate the conditional route you must provide the app server with MAINTENANCE_MODE=true. Note that dotenv files cannot be used to set these envvars locally as the config gem (`settings.yml` file) is loaded before dotenv files.

```bash
# activate maintenance mode locally
MAINTENANCE_MODE=true rails s
```

You can deploy the app in maintenance mode for kubernetes orchestrated environments by deploying either from your local machine or via circleCI. Either method requires you to amend the `deployment.yaml` file for the relevant environment to add the env var `MAINTENANCE_MODE` with a value `'true'`.

example `deployment.yaml` config:
```yaml
env:
  - name: MAINTENANCE_MODE
    value: 'true'
```

To apply via circleCI:

- commit the above change and push to github
- run through circleCI and deploy to the relevant environment
- For production environment you will need to merge to master and use its workflow
- to take site out of maintenance you would have to commit the reverse and redeploy via circleCI


To apply via local machine:

- you will need all relevant aws credentials and git-crypted secrets access
- amend `deployment.yaml`, as above, and run the deploy script, as below.
- to take site out of maintenance amend `MAINTENANCE_MODE` to `'false'` and run the deploy script again.

```bash
# deploying to dev from local machine
kubernetes_deploy/scripts/deploy.sh dev latest
```

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

## Sidekiq Console

To run Sidekiq

```
bundle exec sidekiq
```

To display the current state of the Sidekiq queues, as a logged in superadmin browse to `/sidekiq`

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Anonymised Database Dumps/restores

*WARNING:* not tested since hosting migration

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

For both VAT registered and unregistered LGFS providers, a VAT amount field is provided for manual input of VAT


## Build and Deploy

### CircleCI

CircleCI is configured such that:

1. merges to `master` will automatically build a docker container image for the app, tag it as `app-latest` and push to our AWS elastic container registry (ECR). The image will be smoke tested before then requiring approval for deployment.

2. branches have 2 separate workflows. The first runs the test suite against the branch without any user interaction. The second workflow requires approval to build a container and then enables deployment to individual non-production environments (approval required).

The build and deploy scripts can be found in the root `.circleci` directory.

### Kubernetes

CCCD's stack orchestration tool is kubernetes. Config for kubernetes can be found under the `kubernetes_deploy/` directory. Note, however, that the infrastructure is defined in the [Cloud platform environments repository](https://github.com/ministryofjustice/cloud-platform-environments)

Build and deploy from your local machine can be achieved using scripts in `kubernetes_deploy/scripts` *and can be used once you have access to AWS*. These facilitate the most common tasks, namely build, deploy, apply a job, apply a cronjob.


```
# build and deploy master to dev
kubernetes_deploy/scripts/build.sh
kubernetes_deploy/scripts/deploy.sh dev latest
```

#### Cronjobs

There are two cronjobs, `clean_ecr` and `archive_stale`. Any change to the `archive_stale` jobs config (`kubernetes_deploy/cron_jobs/archive_stale.yml`) are applied as part of the deployment process (because it relies on the app image), but any changes to the standalone `clean_ecr` job need to be applied from the commandline, as below

```
# apply changes to made to `kubernetes_deploy/cron_jobs/clean_ecr.yml`
kubernetes_deploy/scripts/cronjob.sh clean_ecr
```

## Contributing

Bug reports and pull requests are welcome.

1. Fork the project (https://github.com/ministryofjustice/Claim-for-Crown-Court-Defence/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit until you are happy with your contribution (`git commit -am 'Add some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Make sure your changes are covered by tests, so that we don't break it unintentionally in the future.
6. Create a new pull request.

## License

Released under the [MIT License](http://www.opensource.org/licenses/MIT). Copyright (c) 2015-2016 Ministry of Justice.
