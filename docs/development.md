## Development

- [Setting up development environment](#setting-up-development-environment)
- [Sidekiq Console](#sidekiq-console)
- [Scheduled tasks](#scheduled-tasks)
- [Mailer previewing](#mailer-previewing)
- [Anonymised database dump and restore](#anonymised-database-dump-and-restore)
- [A note on architecture](#a-note-on-architecture)

## Other links:
- [Cookie rotation](cookie_rotation.md)
- [Thinkst Canaries](thinkst_canary.md)
- [Govuk-formbuilder migration](govuk-formbuilder_migration.md)

## Setting up development environment

Install Postgres on your local machine. If you would like to use a different database, you may need to update the config/database.yml file

- Install yarn

```
yarn install
```

- Install dependencies

```
# for mac osx
brew bundle
```

- Install node (using projects version `.nvmrc`)

```
nvm install
```

- Install gems and setup database

```
# From the root of the project
bin/setup
```

**NOTE:** You can change the [default values](../.env.sample) for the environment variables as necessary in each of the environment files (e.g. `.env.development` and `.env.test`)

- You may need to build your assets with:

```
bundle exec rails assets:precompile
```
and or
```
yarn build
```

- Load data

```
rails db:drop db:create db:reload
rails claims:demo_data
```

- Run the application server

See note below on architecture for the reason why you need to run two servers.

```
rails server
rails server -p 3001 -P /tmp/rails3001.pid
```

#### Install Libreoffice
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

#### S3 for document storage

AWS S3, the **default** document storage mechanism, is stubbed out
using webmock for all tests, and set to local storage in development mode.

See `config/aws.yaml` and note that because we use the [config](https://github.com/railsconfig/config) gem, secret settings like `Settings.aws.s3.access` require an envvar `SETTINGS__AWS__S3__ACCESS`.

#### Setting up the pre-commit hooks
- [DevSecOps Hooks](https://github.com/ministryofjustice/devsecops-hooks)
  - To avoid committing secrets we use pre-commit hooks configured by DevSecOps. Please install Prek by following the instructions so the hooks can run when you commit your changes.


## Sidekiq Console

To process sidekiq jobs in the *foreground*, in development only, you can set `INLINE_SIDEKIQ` env var to process sidekiq jobs in the foreground. This will output job results (including mail content) to the rails server terminal.

```
# .env.development
INLINE_SIDEKIQ=true
```

To process sidekiq jobs in the *background*, similarly to production, run Sidekiq in a separate terminal.

```
bundle exec sidekiq
```

To display the current state of the Sidekiq queues, as a logged in superadmin browse to `/sidekiq`

## Scheduled tasks

Scheduled tasks are executed using [Sidekiq Scheduler.](https://github.com/sidekiq-scheduler/sidekiq-scheduler)

The schedule is defined in the Sidekiq configuration file, `config/sidekiq.yml`, in the `scheduler` section:

```yaml
:scheduler:
  :schedule:
    poll_injection_responses:
      cron: '0 * * * * *'
      class: Schedule::PollInjectionResponses
```

A scheduled task requires two parameters;

* `cron`; The schedule is defined with the usual crontab options with an
  optional first field allowing accuracy to the second. For example,
  `15 10 * * * *` will run the task at 10 minutes and 15 seconds of every hour
  while `10 * * * *` will run the task during the 10th minute of every hour.
* `class`; The class defining the task to be run. This class expects a method
  `perform` that will be called when the task is executed.

Arguments may be defined for the `perform` method with the optional `args`
parameter.

By convention, our scheduled task classes are in the `lib/schedule` directory
and are in the `Schedule` namespace.

The schedule can be viewed in the Sidekiq section while logged in as
superadmin under the [Recurring Jobs](https://claim-crown-court-defence.service.gov.uk/sidekiq/recurring-jobs) tab.
From here it is possible to disable and enable tasks.

In the development and test environments the scheduled tasks can be removed by
setting `DISABLE_SCHEDULED_TASK` in `.env.development` and `.env.test`. See
`config/initializers/sidekiq.rb`.

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Anonymised database dump and restore

In order to test running of an anonymised dump against your local database you can:

```bash
# run anonymised db dump locally for testing purposes
$ bundle exec rails db:dump:anonymised
```

In order to create an anonymised dump of a hosted environment's database you can:

```bash
# run the db-dump job in the given environment
$ bundle exec rails db:dump:run_job['dev']
```

```bash
# run the db-dump job in the given environment using a built branch docker tag
$ bundle exec rails db:dump:run_job['dev','my-branch-latest']
```

This task requires you have kubectl installed locally.

This will create a `private` dump file in the host environment's s3 bucket and list all such dumps at the end.

 ### Downloading dump files

To download an s3 dump file locally you must first log on to a kubernetes pod in the appropriate namespace:

```bash
# shell into host
kubectl exec -it -n <namespace> <pod-name> -- sh
```

You can then download the dump file to the pod:

```bash
# copy existing dump file from an environment and decompress
bundle exec rails db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','dev']
```

The output will specify the location of the decompressed dump file (`tmp/{environment}/filename`).

You then need to copy the dump file to your local machine:

```bash
# copy dump file from pod
kubectl cp <namespace>/<pod-name>:tmp/dev/20201013214202_dump.psql tmp/dev/20201013214202_dump.psql
```

You can then load the database dump to your local database using:

```bash
bundle exec rails db:restore['local-dump-file-path']
```

Snippet for local dump and restore:

```bash
$ cd <cccd_root>
$ bundle exec rails db:dump:run_job['production'] # optional
$ kubectl exec -it -n cccd-production <pod-name> -- sh
$ bundle exec rails db:dump:list_s3_dumps['production']
   => Key: tmp/20201013214202_dump.psql.gz
      ...
$ bundle exec rails db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','production']
$ exit
$ kubectl cp cccd-production/<pod-name>:tmp/production/20201013214202_dump.psql tmp/production/20201013214202_dump.psql
$ bundle exec rails db:restore['tmp/production/20201013214202_dump.psql']
```

Alternatively, if dump files already exist for the environment, you can list them while logged onto a kubernetes pod
- eg `bundle exec rails db:dump:list_s3_dumps['production]` - and then copy the one you want locally. Dumps are listed in
chronological order, most recent first.

> If you use zsh instead of the bash terminal, you may need to wrap the rake task in a string when passing an array as an argument
> e.g.
> ```zsh
> bundle exec rails 'db:restore['tmp/20231006125624_dump.psql.gz']'
> ```

 ### Deleting dump files

 There is a rake task to delete s3 stored dump files. This will delete all but the latest. This should be run when writing new dump files to avoid storing too many large dump files. You must be logged onto a kubernetes pod to run this task. If you want to delete all you can add a second argument of 'all'.

```bash
# shell into host
$ kubectl exec -it -n cccd-production <pod-name> -- sh

# delete all but the latest dump file
$ bundle exec rails db:dump:delete_s3_dumps['production']

# delete all dump files
$ bundle exec rails db:dump:delete_s3_dumps['production','all']
```

### Restoring a dump on a remote host

Databse dump files can also be restored on a remote host. To achieve this you will need to transfer the dump file to the host and then run the restore task on the host. You should use the worker pod to mitigate impact of restoration on server hosts.

* Create dir on remote host (optional):
  ```bash
  # shell into host
  kubectl exec -it -n <namespace> <pod-name> -- sh

  # create
  /usr/src/app $ mkdir tmp/production
  /usr/src/app $ exit
  ```

* Compress local copy if necessary - to avoid long transfer times
  ```bash
  # compress file but retain uncompressed version
  gzip < dump_file_name.psql.psql > dump_file_name.psql.gz
  ```

* User kubernetes to copy local file to remote host
  ```bash
  # copy source to pod:destination
  kubectl cp tmp/production/dump_file_name.psql.gz <pod-name>:tmp/production/dump_file_name.psql.gz
  ```
  *Note: for a large file, 1G+, this can take 20+ minutes*

* Restore remote database using dumpfile on remote host
  ```bash
  # shell into host
  kubectl exec -n <namespace> -it <pod-name> -- sh

  # restore database
  /usr/src/app $ rails db:restore['tmp/production/dump_file_name.psql.gz']
  ```

## A note on architecture

This app was originally written as a single monolithic application, with the ability to import claims via a public API.  A decision was later taken to split the Caseworker off into a separate application, using the API to communicate to the main app.  This has only partially been
done.

The CaseWorker allocation pages use the API to talk to the main application, rather than access the database directly.  In the local development environment, it accesses another server running on port 3001, which is why you need to start up the second server.
