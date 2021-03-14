RSpec.configure do |config|
  # mute noise for parallel tests
  config.silence_filter_announcements = true if ENV['TEST_ENV_NUMBER']
end
