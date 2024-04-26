# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
if Rails.env.development?
  Rails.application.config.filter_parameters += [
    :password,
    :document
  ]
else
  Rails.application.config.filter_parameters += [
    :password,
    :email,
    :first_name,
    :last_name,
    :date_of_birth,
    :supplier_number,
    :body,
    :document,
    :api_key
  ]
end
