# Thinkst Canary API

## Canarytoken Factory

To facilitate the automation of Canary token creation without requiring the
use of the main auth token a factory auth token can be used, which is a limited
use key that can only be used to create other tokens.

An existing factory auth token can be used with;

```ruby
factory = ThinkstCanary::Factory.new(
  factory_auth: <factory_auth_token>,
  flock_id: 'flock:123...'
)
```

**TODO:** For a `factory` as defined above, query the API to fetch the `flock_id` and `memo`.

To create a new factory auth token;

```ruby
factory_generator = ThinksCanary::FactoryGenerator.new
factory = factory_generator.create_factory(
  flock_id: 'flock:123...',
  memo: 'My shiny new token factory'
)
# => An instance of ThinkstCanary::Factory
```

A factory auth token can be deleted by;

```ruby
factory = ThinkstCanary::Factory.new(factory_auth: <factory_auth_token>)
factory.delete
```

## Creating tokens

A Canary token can be created using a factory;

```ruby
factory = ThinkstCanary::Factory.new(factory_auth: <factory_auth_token>, flock_id: 'flock:123...')
token = factory.create_token(
  kind: <kind of token>,
  memo: 'My shiny new Canary token',
  <other options>
)
```

At the moment, the only token kind is `doc-msword`.

### `doc-msword` tokens

An MS Word token is created with;

```ruby
# File to create the token from
file = File.open('test_file.docx')

token = factory.create_token(
  kind: 'doc-msword',
  memo: 'An MS Word Canary token',
  file: file
)
# => An instance of ThinkstCanary::Token::DocMsword
```

To download the file and save it;

```ruby
File.open('test_file_canary.docx', 'wb') do |file|
  file.puts token.download
end
```

**TODO:** Should `token.download` return an `IO` instead of the contents of the file?

## Rake tasks

Three Rake tasks exist for working with Canary tokens. The following
environment variables need to be set;

* `CANARY_ACCOUNT_ID`
* `CANARY_FACTORY_AUTH_TOKEN`
* `CANARY_FLOCK_ID`

### `canary:create_factory_auth`

Create a new factory auth string.

```bash
rails 'canary:create_factory_auth[A new Canary factory,flock:abc123]'
```

* The first argument is the memo for the new factory auth string and this
  argument is required.
* The second argument is the flock id that the new factory auth string is to be
  attached to. This is optional and the default value is the value of the
  `CANARY_FLOCK_ID` environment variable.

### `canary:delete_factory_auth`

Delete a factory auth string.

```bash
rails 'canary:create_factory_auth[abc123]'
```

* The first argument is the factory auth string to be deleted and this argument
  is required.

### `canary:create_reports_access_details`

Create a new Canary token and saves it as the latest `reports_access_details`
stats report.

```bash
rails canary:create_reports_access_details
```
