module API
  module V1
    module Advocates

      class Fee < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :fees, desc: 'Create or Validate' do

          helpers do

            include API::V1::ApiHelper

            params :fee_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,      desc: "REQUIRED: The API authentication key of the chamber"
              optional :claim_id, type: String,     desc: 'REQUIRED: The unique identifier for the corresponding claim.'
              optional :fee_type_id, type: Integer, desc: 'REQUIRED: The unique identifier for the corresponding FeeType'
              optional :quantity, type: Integer,    desc: 'REQUIRED: The number of Fees being claimed for of this FeeType and Rate'
              optional :amount, type: Float,        desc: 'REQUIRED: Total value.'
            end

            # NOTE: explicit error raising because claim_id's presence is not validated by model due to instatiation issues # TODO review in code review
            def validate_claim_presence
              claim_id = ::Claim.find_by(uuid: params[:claim_id]).try(:id)
              if claim_id.nil?
                raise API::V1::ArgumentError, 'Claim cannot be blank'
              end
              claim_id
            end

            def build_arguments
              claim_id = validate_claim_presence
              {
                claim_id: claim_id,
                fee_type_id: params[:fee_type_id],
                quantity: params[:quantity],
                amount: params[:amount]
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
