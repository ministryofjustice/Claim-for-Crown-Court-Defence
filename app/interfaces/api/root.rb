require 'grape'
require 'grape-swagger'
Dir[File.join(__dir__, 'helpers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '*.rb')].each { |file| require file }

module API
  class Root < Grape::API
    use API::Logger

    helpers API::Helpers::Authorisation
    helpers API::Helpers::ResourceHelper
    helpers API::Helpers::ErrorLoggingHelper

    error_formatter :json, API::Helpers::JsonErrorFormatter

    rescue_from Grape::Exceptions::ValidationErrors, ArgumentError, RuntimeError do |error|
      log_error(400, error)
      error!(error.message, 400)
    end

    rescue_from API::Helpers::Authorisation::AuthorisationError do |error|
      log_error(401, error)
      error!(error.message, 401)
    end

    # Mount the different API versions here
    mount API::V1::Root
    mount API::V2::Root

    # Set the papertrail user 'whodunnit' attribute.
    # Normally 'ExternalUser' or 'Caseworker' via the front-end.
    before do
      set_papertrail_user('API')
    end
  end
end
