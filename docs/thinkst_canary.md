# Canarytokens

Canarytokens are honeypots placed in locations to detect unauthorized access.
There are various types of Canarytokens and each has a 'memo', which is a short
description to help identify which has been triggered when an alert is raised.

* [In CCCD](#in-cccd): How Canarytokens are used in CCCD
* [Rake tasks](#rake-tasks): Details about Rake takss for managing Canarytokens
* [Thinkst Canary API](#thinkst-canary-api): Documentation of the library for communicating with the API
## In CCCD

Canarytokens are place in CCCD in the following places;

| Type | Memo | Notes |
|---|---|---|
| Cloned website | Cloned website detector on claim-crown-court-defence.service.gov.uk | Triggered when CCCD is viewed from an invalid domain. |
| MI Report | Fake reports access details file on '_environment_' - canary_base.docx | A report accessed via a hidden link on the MI report page. [See below.](#mi-report) |
| Dummy files on S3 | _filename_ in the S3 bucket for the '_environment_' environment - canary_base.docx | Two are Canarytokens placed on the S3 buckets for each of the environments. [See below.](#dummy-files-on-s3) |

### MI Report

The MI Report Canarytoken is generated on each environment using the Rake task;

```bash
rails canary:create_reports_access_details
```

### Dummy files on S3

The dummy files for S3 are generated on each envionment using the Rake task;

```bash
rails canary:create_s3_storage_canary
```

**Note:** The commands below for accessing the S3 buckets assume that the
default profile is used. A non-default profile can be used, provided it is
correclty configured, by adding the profile name like;

```bash
aws s3 ls s3://<bucket-name> --profile cccd-s3-staging
```

To view the Canarytokens using the AWS command line;

```bash
aws s3 ls s3://<bucket-name>
# => ...
# => 2021-11-02 09:08:04   12026747 9wihxtojnrxgweviwjdxjq6oeagx
# => 2021-12-01 02:51:19   22471895 abk22g9ma15urhxgz9tho0i83do1
# => 2021-12-05 03:30:27   21687367 ac7hsc7o578qb4062igv6ewene1u
# => 2021-12-13 13:54:06      13302 <canary-file>
# => 2021-12-10 11:26:52   20960626 ae0tvfjb5loiox04glx17ve1cmfn
# => 2021-11-23 13:32:59       2321 ak5q69cwjl1y3409fl4sd28kaanx
# => 2021-10-21 03:30:20       4416 amk1rhq61p9vlmcvqj0wregawo3c
# => ...

The files may be copied locally, if required, using;

```bash
aws s3 cp s3://<bucket-name>/<canary-file> local-copy-of-canary.docx
```

**Note:** Opening these files with MS Word or Adobe Acrobat Reader will trigger
an alert.

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

## Thinkst Canary API

### Quick start

```ruby
# Create a Canarytoken factory
factory = ThinkstCanary::Factory.new(
  factory_auth: <factory_auth_token>,
  flock_id: <flock_id>
)

# Open an existing MS Word document to use as the base for the new Canarytoken
base_file = File.open('base_document.docx')

# Use factory to create an MS Word Canarytoken from the base file
token = factory.create_token(
  kind: 'doc-msword',
  memo: 'Description to help identify the token when an alert is raised',
  file: base_file
)

# Fetch the contents of the newly created CanaryToken
tokenized_file_contents = token.download

# Place the Canarytoken where an intruder may find it
File.open('/path/to/sensitive/files/location/tempting_file_name.docx', 'wb') do |file|
  file.puts tokenized_file_contents
end
```

### Canarytoken Factory

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

**TODO:** For a `factory` as defined above, query the API to fetch the
`flock_id` and `memo`. The API doesn't currently support this.

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

### Creating tokens

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

#### `doc-msword` tokens

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

