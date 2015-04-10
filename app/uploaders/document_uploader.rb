# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  if ENV['cbo_use_s3'] || Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

end
