CarrierWave.configure do |config|
  unless (ENV['cbo_aws_access_key'] && ENV['cbo_secret_access_key'])
    warn "************************************************"
    warn "You have not set `cbo_aws_access_key` or `cbo_secret_access_key` environment variables."
    warn "These are required if you want to run in production mode or use S3 in any other mode."
    warn "************************************************"
    exit
  end

  config.fog_credentials = {
    provider:               'AWS',
    aws_access_key_id:      ENV['cbo_aws_access_key'],
    aws_secret_access_key:  ENV['cbo_secret_access_key'],
    region:                 'eu-west-1'
  }
  config.fog_directory  = ENV['cbo_bucket_name'] || "moj-cbo-documents-#{Rails.env}"
  config.fog_public     = false
  config.fog_attributes = {'Cache-Control': 'no-cache'}
  config.fog_authenticated_url_expiration = 1.hour
end
