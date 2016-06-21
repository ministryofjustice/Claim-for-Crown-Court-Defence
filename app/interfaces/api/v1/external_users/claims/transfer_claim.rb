module API::V1::ExternalUsers
  module Claims
    class TransferClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
      end

      namespace :transfer do
        desc 'Create a Litigator transfer claim.'
        post do
          create_resource(::Claim::TransferClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate a Litigator transfer claim.'
        post '/validate' do
          validate_resource(::Claim::TransferClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end