module API
  module V1
    module ExternalUsers

      class Defendant < Grape::API
        prefix 'api/external_users'

        params do
          optional :api_key, type: String, desc: "REQUIRED: The API authentication key of the provider"
          optional :claim_id, type: String, desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
          optional :first_name, type: String, desc: "REQUIRED: First name of the defedant."
          optional :last_name, type: String, desc: "REQUIRED: Last name of the defendant."
          optional :date_of_birth, type: String, desc: "REQUIRED: Defendant's date of birth (YYYY-MM-DD).", standard_json_format: true
          optional :order_for_judicial_apportionment, type: Boolean, desc: "OPTIONAL: whether or not the defendant is impacted by an order for judicial apportionment (JSON Boolean data type: true or false)"
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
