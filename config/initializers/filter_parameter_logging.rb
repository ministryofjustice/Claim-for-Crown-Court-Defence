# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
if Rails.env.development?
  Rails.application.config.filter_parameters += [
    :password
  ]
else
  Rails.application.config.filter_parameters += [
    :password,
    :email,
    :first_name,
    :last_name,
    :date_of_birth,
    :supplier_number,
    :body
  ]
end

