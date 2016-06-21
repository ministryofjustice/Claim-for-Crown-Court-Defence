module API
  module V1
    module ExternalUsers

      class Expense < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: "REQUIRED: The API authentication key of the provider"
          optional :claim_id, type: String, desc: "REQUIRED: Unique identifier for the claim associated with this expense."
          optional :expense_type_id, type: Integer, desc: "REQUIRED: The unique identifier for the corresponding expense type."
          optional :amount, type: Float, desc: "REQUIRED: The total amount of the expense."
          optional :location, type: String, desc: "REQUIRED for all expense types other than Parking. Location or destination."
          optional :reason_id, type: Integer, desc: "REQUIRED: Unique identifier for the reason for this travel: must be one of the valid reason ids associated with the expense type."
          optional :reason_text, type: String, desc: "REQUIRED when reason is Other oitherwise must be absent."
          optional :distance, type: Integer, desc: "REQUIRED for expense type Car Travel, otherwise must be absent. Distance in miles."
          optional :mileage_rate_id, type: Integer, desc: "REQUIRED for expense type Car Travel, otherwise must be absent: Where applicable. Values should be 1 for 25p per mile, 2 for 45p per mile."
          optional :hours, type: Integer, desc: "REQUIRED for expense type Travel Time, otherwise must be absent. Time in hours."
          optional :date, type: String, desc: "REQUIRED: The date applicable to this Expense (YYYY-MM-DD)", standard_json_format: true
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
