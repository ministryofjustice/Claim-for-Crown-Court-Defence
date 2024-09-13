LAA::Cda.configure do |conf|
  conf.root_url = ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil)
  conf.oauth2_id = ENV.fetch('COURT_DATA_ADAPTOR_API_UID', nil)
  conf.oauth2_secret = ENV.fetch('COURT_DATA_ADAPTOR_API_SECRET', nil)
end
