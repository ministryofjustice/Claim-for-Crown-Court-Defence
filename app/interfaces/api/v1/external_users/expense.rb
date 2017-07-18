module API
  module V1
    module ExternalUsers
      class Expense < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: I18n.t('api.v1.expense.params.api_key')
          optional :claim_id, type: String, desc: I18n.t('api.v1.expense.params.claim_id')
          optional :expense_type_id, type: Integer, desc: I18n.t('api.v1.expense.params.expense_type_id')
          optional :expense_type_unique_code,
                   type: String,
                   desc: I18n.t('api.v1.expense.params.expense_type_unique_code')
          mutually_exclusive :expense_type_id, :expense_type_unique_code
          optional :location, type: String, desc: I18n.t('api.v1.expense.params.location')
          optional :reason_id, type: Integer, desc: I18n.t('api.v1.expense.params.reason_id')
          optional :reason_text, type: String, desc: I18n.t('api.v1.expense.params.reason_text')
          optional :distance, type: Float, desc: I18n.t('api.v1.expense.params.distance')
          optional :mileage_rate_id, type: Integer, desc: I18n.t('api.v1.expense.params.mileage_rate_id')
          optional :hours, type: Float, desc: I18n.t('api.v1.expense.params.hours')
          optional :date, type: String, desc: I18n.t('api.v1.expense.params.date'), standard_json_format: true
          optional :amount, type: Float, desc: I18n.t('api.v1.expense.params.amount')
          optional :vat_amount, type: Float, desc: I18n.t('api.v1.expense.params.vat_amount')
        end

        resource :expenses, desc: 'Create or Validate' do
          helpers do
            def build_arguments
              declared_params.merge(claim_id: claim_id)
            end
          end

          desc 'Create an expense.'
          post do
            create_resource(::Expense)
            status api_response.status
            api_response.body
          end

          desc 'Validate an expense.'
          post '/validate' do
            validate_resource(::Expense)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
