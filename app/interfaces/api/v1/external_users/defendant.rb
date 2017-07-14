module API
  module V1
    module ExternalUsers
      class Defendant < Grape::API
        params do
          optional :api_key, type: String, desc: I18n.t('api.v1.defendant.params.api_key')
          optional :claim_id, type: String, desc: I18n.t('api.v1.defendant.params.claim_id')
          optional :first_name, type: String, desc: I18n.t('api.v1.defendant.params.first_name')
          optional :last_name, type: String, desc: I18n.t('api.v1.defendant.params.last_name')
          optional :date_of_birth,
                   type: String,
                   desc: I18n.t('api.v1.defendant.params.date_of_birth'),
                   standard_json_format: true
          optional :order_for_judicial_apportionment,
                   type: Boolean,
                   desc: I18n.t('api.v1.defendant.params.order_for_judicial_apportionment')
        end

        resource :defendants, desc: 'Create or Validate' do
          helpers do
            def build_arguments
              declared_params.merge(claim_id: claim_id)
            end
          end

          desc 'Create a defendant.'
          post do
            create_resource(::Defendant)
            status api_response.status
            api_response.body
          end

          desc 'Validate a defendant.'
          post '/validate' do
            validate_resource(::Defendant)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
