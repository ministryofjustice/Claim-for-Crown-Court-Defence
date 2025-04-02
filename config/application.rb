require_relative 'boot'

require 'rails/all'

ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] = 'true'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load `.env` earlier in boot sequence for use in settings.yml
Dotenv::Rails.load

# Custom railties that are not gems can be required here
require_relative '../lib/govuk_component'

module AdvocateDefencePayments
  class Application < Rails::Application
    config.load_defaults 7.0

    ### New default configuration for Rails 7.1. To be removed when load_defaults is updated.
    # No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't be able
    # to manually require files that are managed by the autoloader, which you shouldn't do anyway.
    #
    # This will reduce the size of the load path, making `require` faster if you don't use bootsnap, or reduce the size
    # of the bootsnap cache if you use it.
    #
    # To set this configuration, add the following line to `config/application.rb` (NOT this file):
    config.add_autoload_paths_to_load_path = false

    config.middleware.use Rack::Deflater
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'London'

    config.generators do |g|
      g.view_specs false
      g.helper_specs false
    end

    config.assets.enabled = true

    # Non-default config for Rails 6.1
    #
    # This is config that if not set here will accept different
    # defaults from the `config.load_defaults 6.1` command above
    #
    config.action_mailer.deliver_later_queue_name = :mailers
    config.active_record.belongs_to_required_by_default = false
    config.active_record.yaml_column_permitted_classes = [
      ::ActiveRecord::Type::Time::Value,
      ::ActiveSupport::TimeWithZone,
      ::ActiveSupport::TimeZone,
      ::BigDecimal,
      ::Date,
      ::Symbol,
      ::Time
    ]
    config.active_storage.queues.analysis = :active_storage_analysis
    config.active_storage.queues.purge = :active_storage_purge
    config.active_storage.urls_expire_in = 5.minutes # default

    config.autoload_paths << config.root.join('lib')
    config.eager_load_paths << config.root.join('lib')
    config.exceptions_app = self.routes

    config.active_job.queue_adapter = :sidekiq

    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder
  end
end
