source 'https://rubygems.org'
ruby '2.3.0'

gem 'amoeba',                 '~> 3.0.0'
gem 'auto_strip_attributes',  '~> 2.0'
gem 'aws-sdk-v1',             '1.64.0'
gem 'awesome_print'
gem 'breakpoint',             '~> 2.0.7'
gem 'cancancan',              '~> 1.10'
gem 'cocoon',                 '~> 1.2.6'
gem 'devise',                 '~> 3.5.1'
gem 'dropzonejs-rails',       '~> 0.7.1'
gem 'factory_girl_rails',     '~> 4.5.0'
gem 'faker',                  '~> 1.4.3'
gem 'gov_uk_date_fields',     '~> 1.0.5'
gem 'govuk_template',         '~> 0.17.0'
gem 'govuk_frontend_toolkit', '>= 4.6.1'
gem 'govuk_elements_rails',   '>= 1.1.2'
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
gem 'kaminari',               '~> 0.16.2'
gem 'libreconv',              '~> 0.9.0'
gem 'logstasher',             '>= 0.6.5'
gem 'paperclip',              '~> 4.2.2'
gem 'paper_trail',            '~> 4.0.0.rc'
gem 'pg',                     '~> 0.18.2'
gem 'rails',                  '4.2.6'
gem 'rails_config',           '~> 0.5.0.beta1'
gem 'remotipart',             '~> 1.2'
gem 'responder',              '~> 0.2.4'
gem 'rest-client',            '~> 1.8' # needed for scheduled smoke testing plus others
gem 'sass-rails',             '~> 5.0.0'
gem 'scheduler_daemon',       git: 'https://github.com/jalkoby/scheduler_daemon.git'
gem 'susy',	                  '~> 2.2.12'
gem 'select2-rails',          '~> 3.5.9.3'
gem 'sentry-raven',           git: 'https://github.com/getsentry/raven-ruby.git'
gem 'simple_form',            '~> 3.1.0'
gem 'sprockets-rails',        '~> 2.3.3'
gem 'squeel',                 '~> 1.2.3'
gem 'state_machine',          '~> 1.2.0'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'uglifier',                '>= 1.3.0'
gem 'yaml_db'
gem 'zendesk_api'  ,       '1.12.1'
gem 'premailer-rails', '~> 1.9'
gem 'sidekiq', '~> 4.1'

group :production, :devunicorn do
  gem 'rails_12factor', '0.0.3'
  gem 'unicorn-rails',  '2.2.0'
end

group :development, :test do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'guard-livereload', '>= 2.5.2'
  gem 'listen',         '~> 2.10.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rack-livereload', '~> 0.3.16'
  gem 'rspec-rails',    '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'webrick',        '~> 1.3'
  gem 'parallel_tests'
end

group :test do
  gem 'capybara',                   '~> 2.6.2'
  gem 'codeclimate-test-reporter',  require: false
  gem 'cucumber-rails',             require: false
  gem 'database_cleaner',           '~> 1.4.1'
  gem 'kaminari-rspec',             '~> 0.16.1'
  gem 'launchy',                    '~> 2.4.3'
  gem 'poltergeist',                '~> 1.9.0'
  gem 'rspec-mocks',                '~> 3.2.1'
  gem 'shoulda-matchers',           '~> 2.8.0', require: false
  gem 'selenium-webdriver'
  gem 'simplecov',                  require: false
  gem 'simplecov-csv',              require: false
  gem 'simplecov-multi',            require: false
  gem 'i18n-tasks',                 '~> 0.8.7'
  gem 'timecop',                    '~> 0.7.4'
  gem 'webmock',                    '~> 1.21.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
