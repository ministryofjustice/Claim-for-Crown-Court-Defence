module API
  module V2
    module ClaimParamsHelper
      extend Grape::API::Helpers

      params :common_injection_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
        requires :uuid, type: String, desc: 'REQUIRED: Claim UUID'
      end
    end
  end
end
