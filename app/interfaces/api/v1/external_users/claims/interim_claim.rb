module API::V1::ExternalUsers
  module Claims
    class InterimClaim < Grape::API
      helpers API::V1::ClaimParamsHelper

      params do
        use :common_params
        use :common_lgfs_params
        use :common_trial_params
        optional :effective_pcmh_date,
                 type: String,
                 desc: 'REQUIRED/UNREQUIRED: YYYY-MM-DD',
                 standard_json_format: true
        optional :legal_aid_transfer_date,
                 type: String,
                 desc: 'REQUIRED/UNREQUIRED: YYYY-MM-DD',
                 standard_json_format: true
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
