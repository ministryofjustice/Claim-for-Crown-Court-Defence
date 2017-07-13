module API
  module V1
    module ExternalUsers
      class Fee < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: I18n.t('api.v1.external_users.params.api_key')
          optional :claim_id, type: String, desc: I18n.t('api.v1.external_users.params.claim_id')
          optional :fee_type_id, type: Integer, desc: I18n.t('api.v1.external_users.params.fee_type_id')
          optional :fee_type_unique_code,
                   type: String,
                   desc: I18n.t('api.v1.external_users.params.fee_type_unique_code')
          mutually_exclusive :fee_type_id, :fee_type_unique_code
          optional :quantity, type: Float, desc: I18n.t('api.v1.external_users.params.quantity')
          optional :rate, type: Float, desc: I18n.t('api.v1.external_users.params.rate')
          optional :amount, type: Float, desc: I18n.t('api.v1.external_users.params.amount')
          optional :case_numbers, type: String, desc: I18n.t('api.v1.external_users.params.case_numbers')
          optional :date,
                   type: String,
                   desc: I18n.t('api.v1.external_users.params.date'),
                   standard_json_format: true
          optional :warrant_issued_date,
                   type: String,
                   desc: I18n.t('api.v1.external_users.params.warrant_issued_date'),
                   standard_json_format: true
          optional :warrant_executed_date,
                   type: String,
                   desc: I18n.t('api.v1.external_users.params.warrant_executed_date'),
                   standard_json_format: true
        end

        resource :fees, desc: 'Create or Validate' do
          helpers do
            def build_arguments
              declared_params.merge(claim_id: claim_id)
            end
          end

          desc 'Create a fee.'
          post do
            create_resource(::Fee::BaseFee)
            status api_response.status
            api_response.body
          end

          desc 'Validate a fee.'
          post '/validate' do
            validate_resource(::Fee::BaseFee)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
