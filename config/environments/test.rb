require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # logstasher
  # Enable the logstasher logs for the current environment
  config.logstasher.enabled = true

  # This line is optional, it allows you to set a custom value for the @source field of the log event
  config.logstasher.source = 'ccd_test'

  # This line is optional if you do not want to suppress app logs in your <environment>.log
  # config.logstasher.suppress_app_log = true

  # This line is optional if you do not want to log the backtrace of exceptions
  config.logstasher.backtrace = true

  # Enable logging of controller params
  config.logstasher.log_controller_parameters = true

  # log to stdout
  # config.logstasher.logger_path = config.logstasher.logger = Logger.new(STDOUT)

  jsonlogger = LogStuff.new_logger("#{Rails.root}/log/logstash_test.log", Logger::INFO)
  config.logstasher.source = 'ccd_test'
  # Reuse logstasher logger with logstuff
  LogStuff.setup(:logger => jsonlogger)

  config.cache_classes = true

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: ENV["GRAPE_SWAGGER_ROOT_URL"] || 'http://localhost:3000' }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  # TODO: Set this to true, which is the Rails 7.1 default
  config.action_controller.raise_on_missing_callback_actions = false

  # Disable CSS3, jQuery animations and JS popups in test mode for speed, consistency and to avoid timing issues.
  require 'rack/no_animations'
  require 'rack/no_popups'
  config.middleware.use Rack::NoAnimations
  config.middleware.insert_after(Rack::NoAnimations, Rack::NoPopups)
end
