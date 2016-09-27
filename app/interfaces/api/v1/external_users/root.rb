module API
  module V1
    module ExternalUsers
      class Root < API::Helpers::GrapeApiHelper

        version 'v1', using: :accept_version_header, cascade: false
        format :json
        content_type :json, 'application/json'

        group do
          before_validation do
            authenticate_key!
          end

          namespace :api, desc: 'Retrieval, creation and validation operations' do
            mount API::V1::DropdownData

            namespace :external_users do
              mount API::V1::ExternalUsers::Claim
              mount API::V1::ExternalUsers::Defendant
              mount API::V1::ExternalUsers::RepresentationOrder
              mount API::V1::ExternalUsers::Fee
              mount API::V1::ExternalUsers::Expense
              mount API::V1::ExternalUsers::Disbursement
              mount API::V1::ExternalUsers::DateAttended
            end
          end
        end

        add_swagger_documentation(
          info: { title: 'Claim for crown court defence API - v1' },
          api_version: "v1",
          doc_version: 'v1',
          hide_documentation_path: true,
          mount_path: "/api/v1/external_users/swagger_doc",
          hide_format: true
        )
      end
    end
  end
end
