module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Fee < Grape::API

        include ApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :fees, desc: 'Create or Validate' do

          helpers do
            params :fee_creation do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :claim_id, type: String,     desc: 'REQUIRED: The unique identifier for the corresponding claim.'
              optional :fee_type_id, type: Integer, desc: 'REQUIRED: The unique identifier for the corresponding FeeType'
              optional :quantity, type: Integer,    desc: 'REQUIRED: The number of Fees being claimed for of this FeeType and Rate'
              optional :amount, type: Float,        desc: 'REQUIRED: Total value.'
            end

            def build_arguments
              claim_id = ::Claim.find_by(uuid: params[:claim_id]).try(:id)

               # TODO review in code review
               # NOTE: explicit error raising because claim_id's presence is not validated by model due to instatiation issues
              if claim_id.nil?
                raise API::V1::ArgumentError, 'Claim can\'t be blank'
              end

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
            use :fee_creation
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Fee, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a fee."

          params do
            use :fee_creation
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Fee, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end
