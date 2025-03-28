require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # logging
  jsonlogger = LogStuff.new_logger("#{Rails.root}/log/logstash_development.log", Logger::INFO)
  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = false
  config.logstasher.logger = jsonlogger

  # Need to specifically set the logstasher loglevel since it will overwrite the one set earlier
  config.logstasher.log_level = Logger::DEBUG
  config.logstasher.source = 'cccd.development'
  # Reuse logstasher logger with logstuff
  LogStuff.setup(:logger => jsonlogger)
  LogStuff.source = 'cccd.development'

  #Removed to allow for remote device testing (Ipad or other tablets)
  #config.action_controller.asset_host = "http://localhost:3000"

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: ENV["GRAPE_SWAGGER_ROOT_URL"] || 'http://localhost:3000' }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # enable the ability to preview devise emails
  # And index of all can, be viewed at:
  # using webrick defaults at http://localhost:3000/rails/mailers
  config.action_mailer.preview_paths = ["#{Rails.root}/spec/mailers/previews"]

  #Rack livereload for frontend development
  config.middleware.use Rack::LiveReload rescue (puts 'Rack::LiveReload not available')


  # normal dev mail configuration
  config.action_mailer.perform_deliveries = Settings.govuk_notify.api_key.present?
  config.action_mailer.raise_delivery_errors = false

  # config for sending mails from dev
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address:              ENV['SMTP_SERVER'],
  #   port:                 ENV['SMTP_PORT'],
  #   domain:               ENV['SMTP_DOMAIN'],
  #   user_name:            ENV['SMTP_USER'],
  #   password:             ENV['SMTP_PASSWORD'],
  #   authentication:       :login,
  #   enable_starttls_auto: true
  # }
end
