PerformancePlatform.configure do |config|
  config.root_url = 'https://www.performance.service.gov.uk/data'
  config.service = ENV['PERFORMANCE_PLATFORM_SERVICE']
  config.group = ENV['PERFORMANCE_PLATFORM_GROUP']
end
