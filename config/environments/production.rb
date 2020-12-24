Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  PAPERCLIP_STORAGE_OPTIONS = {
    storage: :s3,
    s3_credentials: 'config/aws.yml',
    path: "documents/:id_partition/:filename",
    url: "documents/:id_partition/:filename",
  }

  REPORDER_STORAGE_OPTIONS = {
    storage: :s3,
    s3_credentials: 'config/aws.yml',
    path: "reporders/:id_partition/:filename",
    url: "reporders/:id_partition/:filename"
  }

  REPORTS_STORAGE_OPTIONS = {
    storage: :s3,
    s3_credentials: 'config/aws.yml',
    path: "reports/:filename",
    url: "reports/:filename"
  }

  config.active_storage.service = :local
  # config.active_storage.service = :amazon

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Excluding some endpoints due to ELB only talking HTTP on port 80 and not following redirects to https.
  config.ssl_options = { redirect: { exclude: -> request { request.path =~ /healthcheck|ping/ } } }
  config.force_ssl = true

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  config.action_dispatch.show_exceptions = false

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "advocate_defence_payments_#{Rails.env}"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: ENV['GRAPE_SWAGGER_ROOT_URL'] }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # logging
  jsonlogger = LogStuff.new_logger(STDOUT, Logger::INFO)
  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = true
  config.logstasher.logger = jsonlogger

  # Need to specifically set the logstasher loglevel since it will overwrite the one set earlier
  config.logstasher.log_level = Logger::INFO
  config.logstasher.source = "cccd.production.#{ENV['ENV']}"
  # Reuse logstasher logger with logstuff
  LogStuff.setup(:logger => jsonlogger)
  LogStuff.source = "cccd.production.#{ENV['ENV']}"

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # TODO: remove as NOT AVAILABLE in rails 5.1+
  # This will be be default behaviour in next version of activerecord - early opt-in
  # config.active_record.raise_in_transactional_callbacks = true
end
