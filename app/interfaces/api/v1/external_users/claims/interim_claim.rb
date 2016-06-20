module API::V1::ExternalUsers
  module Claims
    class InterimClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
      end

      namespace :interim do
        desc 'Create a Litigator interim claim.'
        post do
          create_resource(::Claim::InterimClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate a Litigator interim claim.'
        post '/validate' do
          validate_resource(::Claim::InterimClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end