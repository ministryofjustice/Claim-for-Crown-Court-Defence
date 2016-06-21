module API::V1::ExternalUsers
  module Claims
    class InterimClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
        optional :user_email, type: String, desc: 'REQUIRED: The ADP account email address that uniquely identifies the litigator to whom this claim belongs.'
        optional :supplier_number, type: String, desc: 'REQUIRED: The supplier number of the firm submitting the Litigator claim.'
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