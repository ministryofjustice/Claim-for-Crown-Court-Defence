module API
  module V1
    module ExternalUsers
      class Expense < GrapeApiHelper
        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :expenses, desc: 'Create or Validate' do
          helpers do
            params :expense_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,          desc: "REQUIRED: The API authentication key of the provider"
              optional :claim_id, type: String,         desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
              optional :expense_type_id, type: Integer, desc: "REQUIRED: The unique identifier for the corresponding expense type."
              optional :amount, type: Float,            desc: "REQUIRED: The total amount of the expense."
              optional :location, type:  String,        desc: "REQUIRED for all expense types other than Parking. Location or destination."
              optional :reason_id, type: Integer,       desc: "REQUIRED: Unique identifier for the reason for this travel: must be one of the valid reason ids associated with the expense type."
              optional :reason_text, type: String,      desc: "REQUIRED when reason is Other oitherwise must be absent."
              optional :distance, type: Integer,        desc: "REQUIRED for expense type Car Travel, otherwise must be absent. Distance in miles."
              optional :mileage_rate_id, type: Integer, desc: "REQUIRED for expense type Car Travel, otherwise must be absent: Where applicable. Values should be 1 for 25p per mile, 2 for 45p per mile."
              optional :hours, type: Integer,           desc: "REQUIRED for expense type Travel Time, otherwise must be absent. Time in hours."
              optional :date, type: String,             desc: "REQUIRED: The date applicable to this Expense (YYYY-MM-DD)", standard_json_format: true
            end

            def build_arguments
              {
                claim_id: ::Claim::BaseClaim.find_by(uuid: params[:claim_id]).try(:id),
                expense_type_id: params[:expense_type_id],
                location: params[:location],
                amount: params[:amount],
                reason_id: params[:reason_id],
                reason_text: params[:reason_text],
                distance: params[:distance],
                mileage_rate_id: params[:mileage_rate_id],
                hours: params[:hours],
                date: params[:date]
              }
            end
          end

          desc "Create an expense."

          params do
            use :expense_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Expense, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate an expense."

          params do
            use :expense_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Expense, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end
        end
      end
    end
  end
end
