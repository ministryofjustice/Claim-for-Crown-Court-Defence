

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  
  PAPERCLIP_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/test/images/:id_partition/:filename", 
    url: "assets/test/images/:id_partition/:filename"
  }

  REPORDER_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/test/images/reporders/:id_partition/:filename", 
    url: "assets/test/images/reporders/:id_partition/:filename"
  }


  config.action_controller.asset_host = "http://localhost:3000"

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # logstasher
  # Enable the logstasher logs for the current environment
  config.logstasher.enabled = true

  # This line is optional, it allows you to set a custom value for the @source field of the log event
  config.logstasher.source = 'Advocate Defence Payments App test'

  # This line is optional if you do not want to suppress app logs in your <environment>.log
  config.logstasher.suppress_app_log = true

  # This line is optional if you do not want to log the backtrace of exceptions
  config.logstasher.backtrace = true

  # Enable logging of controller params
  config.logstasher.log_controller_parameters = false

  # log to stdout
  config.logstasher.logger_path = config.logstasher.logger = Logger.new(STDOUT)
end
