module API
  module V1
    module ExternalUsers

      class Fee < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :fees, desc: 'Create or Validate' do

          helpers do

            params :fee_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type:      String,  desc: "REQUIRED: The API authentication key of the provider"
              optional :claim_id, type:     String,  desc: 'REQUIRED: The unique identifier for the corresponding claim.'
              optional :fee_type_id, type:  Integer, desc: 'REQUIRED: The unique identifier for the corresponding fee type'
              optional :quantity, type:     Integer, desc: 'REQUIRED: The number of fees of this fee type that are being claimed (quantity x rate will equal amount)'
              optional :rate, type:         Float,   desc: 'REQUIRED/UNREQUIRED: The currency value per unit/quantity of the fee (quantity x rate will equal amount). NB: Leave blank for PPE and NPW fee types'
              optional :amount, type:       Float,   desc: 'REQUIRED/UNREQUIRED: The total value of the fee. NB: Leave blank for fee types other than PPE/NPW'
            end

            # NOTE: explicit error raising because claim_id's presence is not validated by model due to instatiation issues # TODO review in code review
            def validate_claim_presence
              claim_id = ::Claim::BaseClaim.find_by(uuid: params[:claim_id]).try(:id)
              if claim_id.nil?
                raise API::V1::ArgumentError, 'Claim cannot be blank'
              end
              claim_id
            end

            def build_arguments
              claim_id = validate_claim_presence
              {
                claim_id: claim_id,
                fee_type_id:  params[:fee_type_id],
                quantity:     params[:quantity],
                rate:         params[:rate],
                amount:       params[:amount]
              }
            end

          end

          desc "Create a fee."

          params do
            use :fee_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Fee, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a fee."

          params do
            use :fee_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Fee, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end

      end

    end

  end
end