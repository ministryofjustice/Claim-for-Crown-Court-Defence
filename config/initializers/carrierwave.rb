CarrierWave.configure do |config|

  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  elsif Rails.env.development? && !ENV['cbo_use_s3']
    config.storage = :file
  else
    config.fog_credentials = {
      provider:               'AWS',
      aws_access_key_id:      ENV['cbo_aws_access_key'],
      aws_secret_access_key:  ENV['cbo_secret_access_key'],
      region:                 'eu-west-1'
    }
    config.fog_directory  = "moj_cbo_documents_#{Rails.env}"
    config.fog_attributes = {'Cache-Control': 'no-cache'}
  end

end
