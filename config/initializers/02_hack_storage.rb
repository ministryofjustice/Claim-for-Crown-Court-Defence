# TODO: Remove this once config/storage.yml has had these two lines removed

if !ENV['SETTINGS__AWS__S3__ACCESS']
  system("cat config/storage.yml | grep -v access_key_id | grep -v secret_access_key > config/new_storage.yml && mv config/new_storage.yml config/storage.yml")
end