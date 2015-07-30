require 'grape'
require 'grape-swagger'

module API
  module V1
    module Advocates
      class Root < Grape::API
        mount API::V1::Advocates::Claim
        mount API::V1::Advocates::Defendant
        mount API::V1::Advocates::Fee
        mount API::V1::Advocates::Expense
        mount API::V1::Advocates::DateAttended
        mount API::V1::Advocates::RepresentationOrder
        add_swagger_documentation(
          api_version: "v1",
          hide_documentation_path: true,
          mount_path: "/api/v1/advocates/swagger_doc",
          hide_format: true
        )
      end
    end
  end
end
