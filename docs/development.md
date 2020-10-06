## Development

- [Setting up development environment](#setting-up-development-environment)
- [Sidekiq Console](#sidekiq-console)
- [Scheduler daemon](#scheduler-daemon)
- [Mailer previewing](#mailer-previewing)
- [Anonymised Database Dumps and restores](#anonymised-database-dumps-and-restores)
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

## Anonymised Database Dumps and restores

*WARNING: not working since hosting migration*

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

#### A note on architecture

This app was originally written as a single monolithic application, with the ability to import claims via a public API.  A decision was later taken to split the Caseworker off into a separate application, using the API to communicate to the main app.  This has only partially been
done.

The CaseWorker allocation pages use the API to talk to the main application, rather than access the database directly.  In the local development environment, it accesses another server running on port 3001, which is why you need to start up the second server.
