# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
# removed as of Rails 6.0.2+ due to SHA256 hash generation being invalid and therefore assets where blocked by the browser.
# see `config.assets.version` at https://guides.rubyonrails.org/configuring.html
# Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
# Rails.application.config.assets.precompile += %w( adp_swagger_application.js *.png)
# Rails.application.config.assets.precompile += %w( application.test.js ) if Rails.env.test?
# Rails.application.config.assets.precompile += %w( pdf.css )
Rails.application.config.assets.paths << Rails.root.join('node_modules', 'govuk-frontend', 'dist', 'govuk', 'assets')
Rails.application.config.assets.paths << Rails.root.join('node_modules', 'govuk-frontend', 'dist', 'govuk', 'assets', 'images')
Rails.application.config.assets.paths << Rails.root.join('app', 'webpack', 'packs')
Rails.application.config.assets.paths << Rails.root.join('node_modules', '@ministryofjustice', 'frontend', 'moj', 'assets')
