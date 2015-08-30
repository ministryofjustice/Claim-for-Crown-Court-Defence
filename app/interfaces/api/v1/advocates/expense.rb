module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Expense < Grape::API

        include ApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :expenses, desc: 'Create or Validate' do

          helpers do
            params :expense_creation do
              optional :claim_id, type: String, desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
              optional :expense_type_id, type: Integer, desc: "REQUIRED: Reference to the parent expense type."
              optional :quantity, type: Integer, desc: "REQUIRED: Quantity of expenses of this type and rate."
              optional :rate, type: Float, desc: "REQUIRED: Rate for each expense."
              optional :location, type:  String, desc: "Location (e.g. of hotel) where applicable." #TODO add validation to ensure spefici expense types always have a location
            end

            def build_arguments
              {
                claim_id: ::Claim.find_by(uuid: params[:claim_id]).try(:id),
                expense_type_id: params[:expense_type_id],
                quantity: params[:quantity],
                rate: params[:rate],
                location: params[:location]
              }
            end

          end

          desc "Create an expense."

          params do
            use :expense_creation
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Expense, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate an expense."

          params do
            use :expense_creation
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Expense, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end