Rails.application.reloader.to_prepare do
  ThinkstCanary.configure do |config|
    config.account_id = ENV['CANARY_ACCOUNT_ID']
    config.auth_token = ENV['CANARY_AUTH_TOKEN']
  end
end
