MaintenanceMode.configure do |config|
  config.enabled = ENV.fetch('MAINTENANCE_MODE', nil).present?
  config.retry_after = 3600
end
