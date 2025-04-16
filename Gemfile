source 'https://rubygems.org'
ruby file: '.ruby-version'
gem 'active_model_serializers', '~> 0.10.15'
gem 'amoeba',                 '~> 3.3.0'
gem 'auto_strip_attributes',  '~> 2.6.0'
gem 'aws-sdk-s3',             '~> 1'
gem 'aws-sdk-sns',            '~> 1'
gem 'aws-sdk-sqs',            '~> 1'
gem 'awesome_print'
gem 'bootsnap', require: false
gem 'cancancan',              '~> 3.6'
gem 'chartkick',              '~> 5.1.5'
gem 'cocoon',                 '~> 1.2.15'
gem 'csv'
gem 'devise', '~> 4.9.4'
gem 'dotenv-rails', '~> 3.1'
gem 'factory_bot_rails', '~> 6.4.4'
gem 'faker',                  '~> 3.5.1'
gem 'govuk-components', '~> 5.9.0'
gem 'govuk_design_system_formbuilder', '~> 5.9'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'grape', '~> 2.3.0'
gem 'grape-entity',           '~> 1.0.1'
gem 'grape-papertrail',       '~> 0.2.0'
gem 'grape-swagger', '~> 2.1.2'
gem 'grape-swagger-rails', '~> 0.6.0'
gem 'haml-rails', '~> 2.1.0'
gem 'hashdiff',               '>= 1.0.0.beta1', '< 2.0.0'
gem 'hashie-forbidden_attributes', '>= 0.1.1'
gem 'jquery-rails', '~> 4.6.0'
gem 'json-schema',            '~> 5.1.1'
gem 'jsbundling-rails'
gem 'nokogiri',               '~> 1.18'
gem 'libreconv',              '~> 0.9.5'
gem 'logstasher',             '2.1.5'
gem 'logstuff',               '0.0.2'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
gem 'pagy'
gem 'paper_trail', '~> 16.0.0'
gem 'pg',                     '~> 1.5.9'
gem 'rails', '~> 7.1.5'
gem 'redis',                  '~> 5.4.0'
gem 'rubyzip'
gem 'config',                 '~> 5.5' # this gem provides our Settings.xxx mechanism
gem 'remotipart',             '~> 1.4'
gem 'sentry-rails', '~> 5.23'
gem 'sentry-sidekiq', '~> 5.22'
gem 'sprockets-rails', '~> 3.5.2'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'tzinfo-data'
gem 'zendesk_api'  ,           '~> 3.1'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq-failures', '~> 1.0', '>= 1.0.4'
gem 'sidekiq-scheduler', '~> 5.0.6'
gem 'utf8-cleaner',            '~> 1.0'
gem 'tty-spinner'
gem 'ruby-progressbar'
gem 'laa-fee-calculator-client', '~> 2.0'
gem 'active_storage_validations'
gem 'faraday', '~> 2.13'
gem 'faraday-follow_redirects', '~> 0.3'
gem 'puma'
gem 'uri', '< 2.0.0'

gem 'laa-cda', git: 'https://github.com/ministryofjustice/laa-cda'

# Version 1.3.5 of concurrent-ruby removes logger and this causes issues with
# Rails 7.0. It should be possible to remove this restriction when we move to
# Rails 7.1.
# See https://github.com/ruby-concurrency/concurrent-ruby/issues/1077
gem 'concurrent-ruby', '< 1.3.6'

group :development, :test do
  gem 'annotate'
  gem 'brakeman', :require => false
  gem 'better_errors'
  gem 'byebug'
  gem 'listen', '~> 3.9.0'
  gem 'meta_request'
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-livereload', '~> 0.5.2'
  gem 'rspec-rails', '~> 7.1.1'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter'
  gem 'net-ssh', '~> 7.3'
  gem 'net-scp', '~> 4.1'
  gem 'rubocop', '~> 1.75'
  gem 'rubocop-capybara', '~> 2.22'
  gem 'rubocop-factory_bot', '~> 2.27'
  gem 'rubocop-rspec', '~> 3.5'
  gem 'rubocop-rspec_rails', '~> 2.31'
  gem 'rubocop-rails', '~> 2.31'
  gem 'rubocop-performance', '~> 1.25'
  gem 'site_prism', '~> 5.1'
end

group :test do
  gem 'axe-core-cucumber', '~> 4.10'
  gem 'capybara-selenium'
  gem 'capybara', '~> 3.40'
  gem 'cucumber-rails', '~> 3.1.1', require: false
  gem 'database_cleaner'
  gem 'i18n-tasks'
  gem 'json_spec'
  gem 'launchy', '~> 3.1.1'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec-mocks'
  gem 'shoulda-matchers', '~> 6.4'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
