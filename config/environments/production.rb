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

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  config.action_dispatch.show_exceptions = false

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: ENV['GRAPE_SWAGGER_ROOT_URL'] }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false



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



  config.active_record.raise_in_transactional_callbacks = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_SERVER'],
    port:                 ENV['SMTP_PORT'],
    domain:               'advocatedefencepayments.dsd.io',
    user_name:            ENV['SMTP_USER'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       :login,
    enable_starttls_auto: true
  }

  config.action_mailer.perform_deliveries = true
end
