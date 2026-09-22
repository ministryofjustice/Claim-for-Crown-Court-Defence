# CCCD (Claim for Crown Court Defence)

Rails 8.1 app with a PostgreSQL database backend, processing Crown Court defence claims for
advocates, litigators, case workers, provider managers, super admins, and API consumers. The app
also talks to services such as the LAA Fee Calculator, Court Data Adaptor, MAAT, AWS S3/SQS/SNS,
Google Maps, and Zendesk depending on the workflow.

## Build & test

Run commands from the repository root.

```sh
brew bundle
nvm install
yarn install
bin/setup
```

Useful checks:

```sh
yarn build
bundle exec rails assets:precompile
bundle exec rspec
bundle exec cucumber features/path/to.feature:LINE
bundle exec rake jasmine:run
yarn run test:jasmine-headless --filter='Name' --seed 12345
yarn run validate:js
yarn run validate:scss
bundle exec rubocop
bundle exec brakeman
docker build --check --file docker/Dockerfile .
```

- Prefer focused tests or linters for the touched slice before running broad suites.
- Feature specs can be slow; use line-targeted Cucumber scenarios where possible.
- To see a feature test in a real browser, run `BROWSER=chrome bundle exec cucumber <feature file>`.
- Local development often needs two Rails servers: the web app on port 3000 and the internal API on
  port 3001 (`bin/rails server -p 3001 -P tmp/rails3001.pid`). See
  [docs/development.md](../docs/development.md) and [docs/testing.md](../docs/testing.md).
- Pre-commit hooks come from `ministryofjustice/devsecops-hooks` for secret scanning; install them
  per [docs/development.md](../docs/development.md) before committing.

## Architecture

- **Rails app**: controllers, models, forms, services, presenters, validators, and Haml views live
  under `app/`. Keep controllers thin and follow nearby patterns for domain logic placement.
- **API**: the mounted Grape API lives under `app/interfaces/api` and is mounted from
  `config/routes.rb`.
- **Assets on `main`**: JavaScript, Sass, images, and Webpack entry points live under `app/webpack`.
  Webpack is run via `yarn build`; generated assets are not the source of truth unless a task
  explicitly asks to update build output.
- **Background work**: Sidekiq and Sidekiq Scheduler are used for jobs and scheduled tasks. Scheduled
  task classes live under `lib/schedule`.
- **Configuration**: CCCD uses the `config` gem and `Settings`; nested values can be supplied by env
  vars such as `SETTINGS__AWS__S3__ACCESS`.

### VCR and external services

- VCR cassettes live under `vcr/cassettes`. Check [docs/testing.md](../docs/testing.md) before
  changing feature or cassette flows.
- Fee calculator specs/features use `:fee_calc_vcr` and `@fee_calc_vcr`; these have special matching
  and recording behaviour.
- To re-record fee calculator Cucumber cassettes, use `FEE_CALC_VCR_MODE=new_episodes` only for
  tagged scenarios and remove temporary recording changes afterwards.
- A local `LAA_FEE_CALCULATOR_HOST` override can make cassette URIs fail to match recorded
  production-host requests.
- Internal API feature cassettes may require the test API server on port 3001.

### Deployment

- Build/deploy details are in [docs/build_and_deploy.md](../docs/build_and_deploy.md).
- CI runs through `.circleci/config.yml` and builds the application image with `docker/Dockerfile`
  and `.circleci/build.sh`.
- The Docker build precompiles assets in production mode with dummy `SECRET_KEY_BASE` and
  `AWS_REGION` values.
- Runtime filesystem permissions matter because the image switches to a non-root user; create
  writable runtime directories before `USER 1000` or explicitly assign ownership.

## Conventions

- Use Haml for views and the existing GOV.UK/GOV.UK component helpers.
- JavaScript uses neostandard/StandardJS: no semicolons, jQuery globals are expected, and
  vendor/generated paths are ignored by ESLint.
- Sass follows `stylelint-config-gds` plus local project rules.
- Do not convert asset tooling or directory layout opportunistically; keep changes aligned with the
  branch's current asset pipeline.
- Keep commits focused and preserve unrelated user changes. Do not rewrite history, commit, or push
  unless explicitly instructed by the user.
- When changing build, test, deployment, architecture, or major workflow conventions, update this
  file in the same PR if its guidance would become stale.
- When asked to fold fixes into existing commits, use fixup/autosquash against the appropriate
  commit.
- Commit messages should use British English. The title should be imperative and the body should use
  present tense. Filenames, code, and other technical references should be in backticks.

## Additional information

- Setup/runtime docs: [docs/development.md](../docs/development.md)
- Test, lint, and VCR docs: [docs/testing.md](../docs/testing.md)
- Build/deploy docs: [docs/build_and_deploy.md](../docs/build_and_deploy.md)
- CI config: [.circleci/config.yml](../.circleci/config.yml)
- Short command reference: [docs/cheat_sheet.md](../docs/cheat_sheet.md)
- Domain docs: [docs/fee_types.md](../docs/fee_types.md),
  [docs/creating_a_new_fee_scheme.md](../docs/creating_a_new_fee_scheme.md),
  [docs/vat_note.md](../docs/vat_note.md), and [docs/account_setter.md](../docs/account_setter.md)
