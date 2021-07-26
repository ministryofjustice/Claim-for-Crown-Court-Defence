require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load `.env` earlier in boot sequence for use in settings.yml
Dotenv::Railtie.load

# Custom railties that are not gems can be required here
require_relative '../lib/govuk_component'

module AdvocateDefencePayments
  class Application < Rails::Application
    config.load_defaults 6.1
    config.middleware.use Rack::Deflater
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

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
    config.autoloader = :classic
    config.action_mailer.deliver_later_queue_name = :mailers
    config.active_record.belongs_to_required_by_default = false
    config.active_storage.queues.analysis = :active_storage_analysis
    config.active_storage.queues.purge = :active_storage_purge

    config.autoload_paths << config.root.join('lib')

    config.eager_load_paths << config.root.join('lib')

    config.exceptions_app = self.routes

    config.to_prepare do
      Devise::Mailer.layout "email" # email.haml or email.erb
    end

    config.active_job.queue_adapter = :sidekiq
  end
end
