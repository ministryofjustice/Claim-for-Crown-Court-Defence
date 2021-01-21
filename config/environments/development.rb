Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  PAPERCLIP_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "public/assets/dev/images/docs/:id_partition/:filename",
    url: "assets/dev/images/docs/:id_partition/:filename"
  }

  REPORTS_STORAGE_OPTIONS = {
    storage: :filesystem,
    path: "tmp/dev/reports/:filename",
    url: "tmp/dev/reports/:filename"
  }

  config.active_storage.service = :local
  # config.active_storage.service = :amazon

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

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: ENV["GRAPE_SWAGGER_ROOT_URL"] || 'http://localhost:3000' }
  config.action_mailer.asset_host = config.action_mailer.default_url_options[:host]

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # enable the ability to preview devise emails
  # And index of all can, be viewed at:
  # using webrick defaults at http://localhost:3000/rails/mailers
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

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
