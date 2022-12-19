module API::V1::ExternalUsers
  module Claims
    module Litigators
      class HardshipClaim < Grape::API
        helpers API::V1::ClaimParamsHelper, API::V1::HardshipClaimParamsHelper

        params do
          use :lgfs_hardship_params
          use :common_lgfs_params
          if Settings.main_hearing_date_enabled_for_lgfs?
            optional :main_hearing_date,
                     type: String,
                     desc: 'OPTIONAL: The date of the main hearing of the case (YYYY-MM-DD)',
                     standard_json_format: true
          end
        end

        namespace :litigators do
          namespace :hardship do
            desc 'Create a Litigator hardship claim.'
            post do
              create_resource(::Claim::LitigatorHardshipClaim)
              status api_response.status
              api_response.body
            end

            desc 'Validate a Litigator hardship claim.'
            post '/validate' do
              validate_resource(::Claim::LitigatorHardshipClaim)
              status api_response.status
              api_response.body
            end
          end
        end
      end
    end
  end
end
