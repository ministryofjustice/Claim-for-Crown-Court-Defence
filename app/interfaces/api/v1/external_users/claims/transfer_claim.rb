module API::V1::ExternalUsers
  module Claims
    class TransferClaim < Grape::API
      helpers API::V1::ClaimParamsHelper

      params do
        use :common_params
        use :common_lgfs_params
        optional :case_concluded_at,
                 type: String,
                 desc: 'REQUIRED: The date the case concluded (YYYY-MM-DD)',
                 standard_json_format: true
        optional :litigator_type, type: String, desc: 'REQUIRED: New or original.', values: %w[new original]
        optional :elected_case, type: Boolean, desc: 'REQUIRED: Was the case elected? (true or false).'
        optional :transfer_stage_id, type: Integer, desc: 'REQUIRED: When did you start acting?'
        optional :transfer_date,
                 type: String,
                 desc: 'REQUIRED: The date you started acting (YYYY-MM-DD)',
                 standard_json_format: true
        optional :case_conclusion_id,
                 type: Integer,
                 desc: I18n.t('api.v1.external_users.claims.transfer_claim.params.case_conclusion_id')
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
