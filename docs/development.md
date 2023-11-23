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

You can run a multi-process server like unicorn on port 3000. This can be done with the following line, but the BetterErrors page will not work correctly if you get an exceptions.

```
rails server -e devunicorn
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

## Scheduled tasks

TODO

## Mailer previewing

With your local rails server running you can browse to ```http://localhost:3000/rails/mailers``` to view a list of current email templates

## Anonymised database dump and restore

In order to test running of an anonymised dump against your local database you can:

```bash
# run anonymised db dump locally for testing purposes
$ bundle exec rails db:dump:anonymised
```

In order to create an anonymised dump of a hosted environments database you can:

```bash
# run the db-dump job in the given environment
$ bundle exec rake db:dump:run_job['dev']
```

```bash
# run the db-dump job in the given environment using a built branch docker tag
$ bundle exec rake db:dump:run_job['dev','my-branch-latest']
```

This task requires you have kubectl installed locally.

This will create a `private` dump file in the host environments s3 bucket and list all such dumps at the end. If the log tailing times out (it will on production currently) then you will need to list the dump files using:


```bash
# requires kubeconfig secret access
# list existing dump files for an environment
bundle exec rake db:dump:list_s3_dumps['dev']
```

You can then download the s3 dump file locally using:

```bash
# requires kubeconfig secret access
# copy existing dump file from an environment and decompress
bundle exec rake db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','dev']
```

The output will specify the location of the decompressed dump file (`tmp/{environment}/filename`).

You can then load the database dump on to your local database suing:

```bash
bundle exec rake db:restore['local-dump-file-path']
```

Snippet for local dump and restore:

```bash
$ cd <cccd_root>
$ bundle exec rake db:dump:run_job['production'] # optional
$ bundle exec rake db:dump:list_s3_dumps['production']
   => Key: tmp/20201013214202_dump.psql.gz
      ...
$ bundle exec rake db:dump:copy_s3_dump['tmp/20201013214202_dump.psql.gz','production']
$ bundle exec rake db:restore['tmp/production/20201013214202_dump.psql']
```

Alternatively, if dump files already exist for the environment you can list them - `db:dump:list_s3_dumps` - and then copy the one you want locally - they are listed with most recent first.

> If you use zsh instead of the bash terminal, you may need to wrap the rake task in a string when passing an array as an argument
> e.g.
> ```zsh
> bundle exec rails 'db:restore['tmp/20231006125624_dump.psql.gz']'
> ```

 ### Deleting dump files

 There is a rake task to delete s3 stored dump files. This will delete all but the latest. This should be run when writing new dump files to avoid storing too many large dump files. If you want to delete all you can add a second argument of 'all'

```bash
# delete all but the latest dump file
$ bundle exec rake db:dump:delete_s3_dumps['production']

# delete all dump files
$ bundle exec rake db:dump:delete_s3_dumps['production','all']
```

### Restoring dump on remote host

The dump files can be restored on a remote host as well. To achieve this you will need to transfer the dump file to the host and then run the restore task on the host. You should use the worker pod to mitigate impact of restore on server hosts.

* Create dir on remote host (optional):
  ```bash
  # shell into host
  kubectl exec -it <pod-name> sh

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
  kubectl exec -it <pod-name> sh

  # restore database
  /usr/src/app $ rake db:restore['tmp/production/dump_file_name.psql.gz']
  ```

#### A note on architecture

This app was originally written as a single monolithic application, with the ability to import claims via a public API.  A decision was later taken to split the Caseworker off into a separate application, using the API to communicate to the main app.  This has only partially been
done.

The CaseWorker allocation pages use the API to talk to the main application, rather than access the database directly.  In the local development environment, it accesses another server running on port 3001, which is why you need to start up the second server.
