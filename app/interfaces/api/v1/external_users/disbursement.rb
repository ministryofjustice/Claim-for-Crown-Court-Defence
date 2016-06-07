module API
  module V1
    module ExternalUsers

      class Disbursement < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :disbursements, desc: 'Create or Validate' do

          helpers do
            params :disbursement_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key,              type: String,  desc: "REQUIRED: The API authentication key of the provider"
              optional :claim_id,             type: String,  desc: "REQUIRED: Unique identifier for the claim associated with this disbursement."
              optional :disbursement_type_id, type: Integer, desc: "REQUIRED: The unique identifier for the corresponding disbursement type."
              optional :net_amount,           type: Float,   desc: "REQUIRED: The net amount of the disbursement."
              optional :vat_amount,           type: Float,   desc: "REQUIRED: The VAT amount of the disbursement."
              optional :total,                type: Float,   desc: "REQUIRED: The total amount of the disbursement."
            end

            def build_arguments
              {
                claim_id: ::Claim::BaseClaim.find_by(uuid: params[:claim_id]).try(:id),
                disbursement_type_id: params[:disbursement_type_id],
                net_amount: params[:net_amount],
                vat_amount: params[:vat_amount],
                total: params[:total]
              }
            end
          end

          desc "Create a disbursement."

          params do
            use :disbursement_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Disbursement, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a disbursement."

          params do
            use :disbursement_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Disbursement, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end
      end
    end
  end
end
