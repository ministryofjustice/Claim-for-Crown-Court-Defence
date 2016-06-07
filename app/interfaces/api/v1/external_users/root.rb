require 'grape'
require 'grape-swagger'

module API
  module V1
    module ExternalUsers
      class Root < Grape::API
        # override default json format for multiple grape validation errors
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          @errs = []
          grape_validation_errors = e.message.split(', ')
          grape_validation_errors.each do |msg|
            @errs.push({error: msg})
          end
          rack_response(@errs.to_json, 400)
        end

        mount API::V1::ExternalUsers::Claim
        mount API::V1::ExternalUsers::Defendant
        mount API::V1::ExternalUsers::Fee
        mount API::V1::ExternalUsers::Expense
        mount API::V1::ExternalUsers::DateAttended
        mount API::V1::ExternalUsers::RepresentationOrder
        mount API::V1::DropdownData

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
