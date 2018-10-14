MaintenanceMode.configure do |config|
  # route all paths to maintenance page
  config.enabled = ENV['MAINTENANCE_MODE'].present?

  # set Retry-After (seconds) header to be a good http citizen
  config.retry_after = 3600
end