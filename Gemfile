source 'https://rubygems.org'
ruby '2.2.3'

gem 'auto_strip_attributes',  '~> 2.0'
gem 'aws-sdk-v1',             '1.64.0'
gem 'bourbon',                '~> 3.2.4'
gem 'breakpoint',             '~> 2.0.7'
gem 'cancancan',              '~> 1.10'
gem 'cocoon',                 '~> 1.2.6'
gem 'devise',                 '~> 3.5.1'
gem 'dropzonejs-rails',       '~> 0.7.1'
gem 'factory_girl_rails',     '~> 4.5.0'
gem 'faker',                  '~> 1.4.3'
gem 'flip',                   '~> 1.0.1'
gem 'govuk_frontend_toolkit', '~> 1.3.0'
gem 'govuk_template',         '~> 0.8.1'
gem 'grape',                  '>= 0.12'
gem 'grape-papertrail'
gem 'grape-swagger',          '>= 0.10.1'
gem 'grape-swagger-rails',    '>= 0.1.0'
gem 'haml',                   '~> 4.0.6'
gem 'haml-rails',             '~> 0.9.0'
gem 'hashie-forbidden_attributes', '>= 0.1.1'
gem 'jbuilder',               '~> 2.2.16'
gem 'jquery-rails',           '~> 3.1.2'
gem 'json-schema'
gem 'json-schema-generator'
gem 'libreconv',              '~> 0.9.0'
gem 'logstasher',             '>= 0.6.5'
gem 'moj_internal_template',  '~> 0.1.9'
gem 'neat',                   '~> 1.5.1'
gem 'paperclip',              '~> 4.2.2'
gem 'paper_trail',            '~> 4.0.0.rc'
gem 'pg',                     '~> 0.18.2'
gem 'rails',                  '4.2.4'
gem 'rails_config',           '~> 0.5.0.beta1'
gem 'remotipart',             '~> 1.2'
gem 'responder',              '~> 0.2.4'
gem 'rest-client',            '~> 1.8' # needed for scheduled smoke testing plus others
gem 'sass-rails',             '~> 4.0.4'
gem 'select2-rails',          '~> 3.5.9.3'
gem 'simple_form',            '~> 3.1.0'
gem 'squeel',                 '~> 1.2.3'
gem 'state_machine',          '~> 1.2.0'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'uglifier',                '>= 1.3.0'
gem 'gov_uk_date_fields',      '0.0.2'
gem 'yaml_db'

group :production, :devunicorn do
  gem 'rails_12factor', '0.0.3'
  gem 'unicorn-rails',  '2.2.0'
end

group :development, :test do
  gem 'annotate'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'listen',         '~> 2.10.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rspec-rails',    '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'webrick',        '~> 1.3'
end

group :test do
  gem 'capybara',                   '~> 2.4'
  gem 'codeclimate-test-reporter',  require: false
  gem 'cucumber-rails',             require: false
  gem 'database_cleaner',           '~> 1.4.1'
  gem 'launchy',                    '~> 2.4.3'
  gem 'poltergeist',                '~> 1.6.0'
  gem 'rspec-mocks',                '~> 3.2.1'
  gem 'shoulda-matchers',           '~> 2.8.0', require: false
  gem 'selenium-webdriver'
  gem 'simplecov',                  require: false
  gem 'simplecov-csv',              require: false
  gem 'simplecov-multi',            require: false
  gem 'timecop',                    '~> 0.7.4'
  gem 'webmock',                    '~> 1.21.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
