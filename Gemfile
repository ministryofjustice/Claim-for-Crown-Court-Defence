source 'https://rubygems.org'
ruby '2.4.2'
gem 'dotenv-rails', groups: [:development, :test]
gem 'amoeba',                 '~> 3.1'
gem 'auto_strip_attributes',  '~> 2'
gem 'aws-sdk',                '~> 2'
gem 'awesome_print'
gem 'cancancan',              '~> 1.15'
gem 'cocoon',                 '~> 1.2.6'
gem 'devise',                 '~> 3.5.1'
gem 'dropzonejs-rails',       '~> 0.7'
gem 'factory_bot_rails',     '~> 4.7'
gem 'faker',                  '~> 1.8.4'
gem 'gov_uk_date_fields',     '= 1.2.3'
gem 'govuk_template',         '~> 0.18.0'
gem 'govuk_frontend_toolkit', '~> 4.6.1'
gem 'govuk_elements_rails',   '~> 1.1.2'
gem 'govuk_notify_rails'
gem 'grape',                  '0.19.2'
gem 'grape-entity',           '~> 0.5.1'
gem 'grape-papertrail',       '~> 0.1.1'
gem 'grape-swagger',          '~> 0.23.0'
gem 'grape-swagger-rails',    '~> 0.2.2'
gem 'haml-rails',             '~> 0.9.0'
gem 'hashie-forbidden_attributes', '>= 0.1.1'
gem 'jquery-rails',           '~> 4.1.1'
gem 'json-schema',            '~> 2.6.2'
gem 'nokogiri',               '~> 1.8'
gem 'kaminari',               '~> 0.16.2'
gem 'libreconv',              '~> 0.9.0'
gem 'logstasher',             '0.6.2'
gem 'logstuff',               '0.0.2'
gem 'paperclip',              '~> 5.2.0'
gem 'paper_trail',            '4.0.2' # version locked, https://github.com/airblade/paper_trail/issues/738
gem 'pdf-forms'
gem 'pg',                     '~> 0.18.2'
gem 'rails',                  '~> 4.2'
gem 'redis',                  '~> 3.3.1'
gem 'rubyzip'
gem 'config',                 '~> 1.2' # this gem provides our Settings.xxx mechanism
gem 'remotipart',             '~> 1.2'
gem 'rest-client',            '~> 2.0' # needed for scheduled smoke testing plus others
gem 'sass-rails',             '~> 5.0.6'
gem 'scheduler_daemon',       git: 'https://github.com/jalkoby/scheduler_daemon.git'
gem 'susy',	                  '~> 2.2.12'
gem 'sentry-raven',           '~> 1.2.2'
gem 'simple_form',            '~> 3.1.0'
gem 'sinatra',                '~> 1.4.7', require: false
gem 'sprockets-rails',        '~> 2.3.3'
gem 'squeel',                 '~> 1.2.3'
gem 'state_machine',          '~> 1.2.0'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'uglifier',                '>= 1.3.0'
gem 'zendesk_api'  ,           '1.12.1'
gem 'sidekiq',                 '4.1.2' # version locked, as 4.1.3 forces Sinatra dependency
gem 'utf8-cleaner',            '~> 0.2'
gem 'colorize'
gem 'shell-spinner', '~> 1.0', '>= 1.0.4'
gem 'ruby-progressbar'
gem 'geckoboard-ruby'
gem 'posix-spawn', '~> 0.3.13'

group :production, :devunicorn do
  gem 'rails_12factor', '0.0.3'
  gem 'unicorn-rails', '2.2.0'
  gem 'unicorn-worker-killer', '~> 0.4.4'
end

group :development, :devunicorn do
  gem 'meta_request'
  gem 'rubocop', '~> 0.50'
end

group :development, :devunicorn, :test do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'fuubar'
  gem 'guard-livereload',   '>= 2.5.2'
  gem 'listen',             '~> 2.10.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rack-livereload',    '~> 0.3.16'
  gem 'rspec-rails',        '~> 3.4'
  gem 'rspec-collection_matchers'
  gem 'puma'
  gem 'parallel_tests'
  gem 'site_prism'
  gem 'guard-jasmine',      '~> 2.0'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-cucumber'
  gem 'net-ssh'
  gem 'net-scp'
end

group :test do
  gem 'capybara',                   '~> 2.6.2'
  gem 'climate_control'
  gem 'codeclimate-test-reporter',  require: false
  gem 'cucumber-rails',             require: false
  gem 'database_cleaner'
  gem 'json_spec', '~> 1.1', '>= 1.1.5'
  gem 'kaminari-rspec',             '~> 0.16.1'
  gem 'launchy',                    '~> 2.4.3'
  gem 'poltergeist',                '~> 1.9.0'
  gem 'rspec-mocks',                '~> 3.4'
  gem 'shoulda-matchers',           '~> 3.1', require: false
  gem 'selenium-webdriver'
  gem 'simplecov',                  require: false
  gem 'simplecov-csv',              require: false
  gem 'simplecov-multi',            require: false
  gem 'i18n-tasks'
  gem 'timecop'
  gem 'vcr',                        '~> 3.0.3'
  gem 'webmock',                    '~> 3.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
