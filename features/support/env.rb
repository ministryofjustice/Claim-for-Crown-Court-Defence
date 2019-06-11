# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["ENV"] ||= 'test'

require 'capybara'
require 'capybara/cucumber'
require 'selenium/webdriver'
require 'webdrivers'
require 'cucumber/rails'
require 'cucumber/rspec/doubles'
require 'site_prism'
require 'sidekiq/testing'
require_relative '../page_objects/base_page'
require_relative '../../spec/vcr_helper'
require_relative '../../spec/support/factory_helpers'

# enable forgery protection in feature tests so as not to obscure
# loss of signed in user
ActionController::Base.allow_forgery_protection = true

# Activate to view chromedriver detailed output
# Webdrivers.logger.level = :DEBUG

# pin version to 2.46 of chromedriver as latest
# version (75.0.3770.80) is not running headless.
# see https://chromedriver.storage.googleapis.com/index.html
# for usable version numbers and review later.
#
Webdrivers::Chromedriver.required_version = '2.46'

# The `webdriver` gem's requests to download drivers is being blocked by Webmock
# without this.
# see https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
# for details
allowed_sites = [
  "https://chromedriver.storage.googleapis.com",
  "https://github.com/mozilla/geckodriver/releases",
  "https://selenium-release.storage.googleapis.com",
  "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver",
]
WebMock.disable_net_connect!(allow_localhost: true, allow: allowed_sites)

# set minimum threads to 0 (to allow shutdown?!)
# and max threads to 5 (duplicate default development
# settings)
#
Capybara.register_server :puma do |app, port, host|
  require 'rack/handler/puma'
  Rack::Handler::Puma.run(app, Host: host, Port: port, Threads: "0:5")
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1366,768) }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

# use headless chrome for javascript
Capybara.javascript_driver = :headless_chrome

Capybara.configure do |config|
  config.default_max_wait_time = 10 # seconds
end

if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.configure do |config|
    config.default_max_wait_time = 10 # seconds
    config.javascript_driver = :chrome
  end
end

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.clean_with(:deletion)
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
  # Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
  #   # { :except => [:widgets] } may not do what you expect here
  #   # as Cucumber::Rails::Database.javascript_strategy overrides
  #   # this setting.
  #   DatabaseCleaner.strategy = :truncation
  #   Cucumber::Rails::Database.javascript_strategy = :truncation
  # end

#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#
