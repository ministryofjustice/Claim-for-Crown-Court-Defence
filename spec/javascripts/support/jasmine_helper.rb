#Use this file to set/override Jasmine configuration options
#You can remove it if you don't need it.
#This file is loaded *after* jasmine.yml is interpreted.
#
#Example: using a different boot file.
#Jasmine.configure do |config|
#   config.boot_dir = '/absolute/path/to/boot_dir'
#   config.boot_files = lambda { ['/absolute/path/to/boot_dir/file.js'] }
#end
#
require 'jasmine/runners/selenium'
require 'webdrivers'

# pin chromedriver version to latest compatible found
# see https://chromedriver.storage.googleapis.com/index.html
# Webdrivers.logger.level = :DEBUG
# Webdrivers::Chromedriver.required_version = '79.0.3945.36'
Webdrivers::Chromedriver.required_version = '71.0.3578.137'

Jasmine.configure do |config|
  config.runner = lambda { |formatter, jasmine_server_url|
    options = Selenium::WebDriver::Chrome::Options.new
    options.headless!

    webdriver = Selenium::WebDriver.for(:chrome, options: options)
    Jasmine::Runners::Selenium.new(formatter, jasmine_server_url, webdriver, 50)
  }
end
