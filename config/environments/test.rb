Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  PAPERCLIP_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/test/images/:id_partition/:filename",
    url: "assets/test/images/:filename"
  }

  REPORDER_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/test/images/reporders/:id_partition/:filename",
    url: "assets/test/images/reporders/:filename"
  }

  REPORTS_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "tmp/test/reports/:filename",
    url: "tmp/test/reports/:filename"
  }

  config.active_storage.service = :test

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

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  # ----------------------------------------------------------------
  # Setting to true to avoid LoadError problems for which i can find
  # no other solution. Specifically the cucumber test suite encounters
  # `<LoadError: Unable to autoload constant ExternalUsers::Fees::PricesController...`
  # if not eagerloaded. Need to look at excluding some lib folders and ensuring
  # we are using Zeitwork mode really.
  config.eager_load = true

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = false
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
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Disable CSS3, jQuery animations and JS popups in test mode for speed, consistency and to avoid timing issues.
  config.middleware.use Rack::NoAnimations
  config.middleware.insert_after(Rack::NoAnimations, Rack::NoPopups)
end
