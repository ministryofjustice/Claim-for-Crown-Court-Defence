PerformancePlatform.configure do |config|
  config.root_url = ENV['PERFORMANCE_PLATFORM_ENDPOINT'] if ENV['PERFORMANCE_PLATFORM_ENDPOINT']
  config.service = ENV['PERFORMANCE_PLATFORM_SERVICE']
  config.group = ENV['PERFORMANCE_PLATFORM_GROUP']
end
