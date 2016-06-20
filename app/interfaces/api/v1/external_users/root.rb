require 'grape'
require 'grape-swagger'

module API
  module V1
    module ExternalUsers
      class Root < API::V1::GrapeApiHelper

        helpers API::Authorisation
        helpers API::V1::ResourceHelper

        # override default json format for multiple grape validation errors
        rescue_from Grape::Exceptions::ValidationErrors, API::V1::ArgumentError do |error|
          errors = error.message.split(', ').collect { |msg| {error: msg} }
          error!(errors, 400)
        end

        rescue_from API::Authorisation::AuthorisationError do |error|
          error!([{error: error.message}], 401)
        end

        group do
          before do
            authenticate_key!
          end

          mount API::V1::ExternalUsers::Claim
          mount API::V1::ExternalUsers::Defendant
          mount API::V1::ExternalUsers::RepresentationOrder
          mount API::V1::ExternalUsers::Fee
          mount API::V1::ExternalUsers::Expense
          mount API::V1::ExternalUsers::Disbursement
          mount API::V1::ExternalUsers::DateAttended
          mount API::V1::DropdownData
        end

        add_swagger_documentation(
          api_version: "v1",
          hide_documentation_path: true,
          mount_path: "/api/v1/external_users/swagger_doc",
          hide_format: true
        )
      end
    end
  end
end
