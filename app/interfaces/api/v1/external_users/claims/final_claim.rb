module API::V1::ExternalUsers
  module Claims
    class FinalClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
      end

      namespace :final do
        desc 'Create a Litigator final claim.'
        post do
          create_resource(::Claim::LitigatorClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate a Litigator final claim.'
        post '/validate' do
          validate_resource(::Claim::LitigatorClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end