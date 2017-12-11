module API
  module V1
    module ExternalUsers
      class Disbursement < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
          optional :claim_id, type: String, desc: I18n.t('api.v1.external_users.params.claim_id')
          optional :disbursement_type_id,
                   type: Integer,
                   desc: I18n.t('api.v1.external_users.params.disbursement_type_id')
          optional :disbursement_type_unique_code,
                   type: String,
                   desc: I18n.t('api.v1.external_users.params.disbursement_type_unique_code')
          mutually_exclusive :disbursement_type_id, :disbursement_type_unique_code
          optional :net_amount, type: Float, desc: 'REQUIRED: The net amount of the disbursement.'
          optional :vat_amount, type: Float, desc: 'REQUIRED: The VAT amount of the disbursement.'
          optional :total, type: Float, desc: 'REQUIRED: The total amount of the disbursement.'
        end

        resource :disbursements, desc: 'Create or Validate' do
          helpers do
            def build_arguments
              declared_params.merge(claim_id: claim_id)
            end
          end

          desc 'Create a disbursement.'
          post do
            create_resource(::Disbursement)
            status api_response.status
            api_response.body
          end

          desc 'Validate a disbursement.'
          post '/validate' do
            validate_resource(::Disbursement)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
