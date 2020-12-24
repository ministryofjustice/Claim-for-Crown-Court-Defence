Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  PAPERCLIP_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/dev/images/docs/:id_partition/:filename",
    url: "assets/dev/images/docs/:id_partition/:filename"
  }

  REPORDER_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/dev/images/reporders/:id_partition/:filename",
    url: "assets/dev/images/reporders/:id_partition/:filename"
  }

  REPORTS_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "tmp/dev/reports/:filename",
    url: "tmp/dev/reports/:filename"
  }

  config.active_storage.service = :local

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

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # This will be be default behaviour in next version of activerecord - early opt-in
  # TODO: remove as NOT AVAILABLE in rails 5.1+
  # config.active_record.raise_in_transactional_callbacks = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: ENV["GRAPE_SWAGGER_ROOT_URL"] || 'localhost:3000' }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]

  # enable the ability to preview devise emails
  # And index of all can, be viewed at:
  # using webrick defaults at http://localhost:3000/rails/mailers
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  config.action_mailer.perform_deliveries = false
  config.action_mailer.delivery_method = :file

  # set local dev vars, uncomment and change delivery_emthod to :smtp
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
