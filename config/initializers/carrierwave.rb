CarrierWave.configure do |config|
  if (ENV['cbo_use_s3'] || Rails.env.production?)
    #unless (ENV['cbo_aws_access_key'] && ENV['cbo_secret_access_key'])
      puts "************************"
      puts "You have not set `cbo_aws_access_key` or `cbo_secret_access_key` environment variables."
      puts "************************"
    #end

    config.fog_credentials = {
      provider:               'AWS',
      aws_access_key_id:      ENV['cbo_aws_access_key'],
      aws_secret_access_key:  ENV['cbo_secret_access_key'],
      region:                 'eu-west-1'
    }
    config.fog_directory  = "moj_cbo_documents_#{Rails.env}"
    config.fog_public     = false
    config.fog_attributes = {'Cache-Control': 'no-cache'}

  elsif (Rails.env.test? || Rails.env.cucumber?)

    config.storage = :file
    config.enable_processing = false

  else

    config.storage = :file

  end
end
