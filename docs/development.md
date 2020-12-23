## Development

- [Setting up development environment](#setting-up-development-environment)
- [Sidekiq Console](#sidekiq-console)
- [Scheduler daemon](#scheduler-daemon)
- [Mailer previewing](#mailer-previewing)
- [Anonymised database dump and restore](#anonymised-database-dump-and-restore)
- [A note on architecture](#a-note-on-architecture)

## Setting up development environment

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

- Load data

```
rake db:drop db:create db:reload
```

- Run the application server

See note below on architecture for the reason why you need to run two servers.

```
rails server
rails server -p 3001 -P /tmp/rails3001.pid
```

You can run a multi-process server like unicorn on port 3000. This can be done with the following line, but the BetterErrors page will not work correctly if you get an exceptions.

```
rails server -e devunicorn
```

#### Install wkhtmltopdf
Install [wkhtmltopdf](http://macappstore.org/wkhtmltopdf) - used to generate PDFs from html templates. You will need to install this locally.

```bash
# for mac osx
brew cask install wkhtmltopdf
```
or
```bash
brew bundle
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

## Scheduler daemon

To process scheduler daemon jobs in development run the scheduler in a terminal and set the relevant scheduler "task" to run regularly (see [scheduled_tasks](../scheduled_tasks) directory)

see [schedular_daemon](https://github.com/ssoroka/scheduler_daemon) for details.

```
# run scheduler daemon in console mode
bundle exec scheduler_daemon run
```

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Anonymised database dump and restore

In order to create an anonymised dump of an environments database you can:

```bash
# run the db-dump job in the given environment
$ rake db:dump:run_job['dev']
```

This task requires you have kubectl installed locally and access to git-crypted secrets.

This will create a `private` dump file in the host environments s3 bucket and list all such dumps at the end. If the log tailing times out (it will on production currently) then you will need to list the dump files using:


```bash
# requires live-1 kubeconfig secret access
# list existing dump files for an environment
rake db:dump:list_s3_dumps['dev']
```

You can then download the s3 dump file locally using:

```bash
# requires live-1 kubeconfig secret access
# copy existing dump file from an environment and decompress
rake db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','dev']
```

The output will specify the location of the decompressed dump file (`tmp/{environment}/filename`).

You can then load the database dump on to your local database suing:

```bash
$ rake db:restore['local-dump-file-path']
```

Snippet for local dump and restore:

```bash
$ cd <cccd_root>
$ rake db:dump:run_job['production'] # optional
$ rake db:dump:list_s3_dumps['production']
   => Key: tmp/20201013214202_dump.psql.gz
      ...
$ rake db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','production']
$ rake db:restore['tmp/production/20201013214202_dump.psql']
```

Alternatively, if dump files already exist for the environment you can list them - `db:dump:list_s3_dumps` - and then copy the one you want locally - they listed most recent first. You can also use `db:dump:list_s3_dumps` task to retrieve time-limited presigned s3 urls that can be used to download the file.

 ### Deleting dump files

 There is a rake task to delete s3 stored dump files. This will delete all but the latest. This should be run when writing new dump files to avoid storing too many large dump files. If you want to delete all you can add a second argument of 'all'

```bash
# delete all but the latest dump file
$ rake db:dump:delete_s3_dumps['production']

# delete all dump files
$ rake db:dump:delete_s3_dumps['production','all']
```

#### A note on architecture

This app was originally written as a single monolithic application, with the ability to import claims via a public API.  A decision was later taken to split the Caseworker off into a separate application, using the API to communicate to the main app.  This has only partially been
done.

The CaseWorker allocation pages use the API to talk to the main application, rather than access the database directly.  In the local development environment, it accesses another server running on port 3001, which is why you need to start up the second server.
