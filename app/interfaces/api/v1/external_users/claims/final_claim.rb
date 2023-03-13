module API
  module V1
    module ExternalUsers
      module Claims
        class FinalClaim < Grape::API
          helpers API::V1::ClaimParamsHelper

          params do
            use :common_params
            use :common_lgfs_params
            optional :case_concluded_at,
                     type: String,
                     desc: 'REQUIRED: The date the case concluded (YYYY-MM-DD)', standard_json_format: true
            optional :actual_trial_length,
                     type: Integer,
                     desc: 'REQUIRED/UNREQUIRED: The actual trial length in days, required for graduated fees.'
            optional :main_hearing_date,
                     type: String,
                     desc: 'OPTIONAL: The date of the main hearing of the case (YYYY-MM-DD)',
                     standard_json_format: true
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
  end
end
