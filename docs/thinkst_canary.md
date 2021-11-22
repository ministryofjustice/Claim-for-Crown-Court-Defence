# Thinkst Canary API

## Canarytoken Factory

To facilitate the automation of Canary token creation without requiring the
use of the main auth token a factory auth token can be used, which is a limit
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