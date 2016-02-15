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
              optional :quantity, type: Float,          desc: "REQUIRED: The number of expenses of this type that are being claimed (quantity x rate will equal amount). rounded to nearest quarter."
              optional :rate, type: Float,              desc: "REQUIRED: The currency value per unit/quantity of the expense (quantity x rate will equal amount)."
              optional :location, type:  String,        desc: "OPTIONAL: Location (e.g. of hotel) where applicable."
            end

            def build_arguments
              {
                claim_id: ::Claim::BaseClaim.find_by(uuid: params[:claim_id]).try(:id),
                expense_type_id: params[:expense_type_id],
                quantity: params[:quantity],
                rate: params[:rate],
                location: params[:location]
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