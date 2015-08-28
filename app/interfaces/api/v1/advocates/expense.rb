module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Expense < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :expenses, desc: 'Create or Validate' do

          helpers do
            params :expense_creation do
              requires :claim_id, type: String, desc: "Unique identifier for the claim associated with this defendant."
              requires :expense_type_id, type: Integer, desc: "Reference to the parent expense type."
              requires :quantity, type: Integer, desc: "Quantity of expenses of this type and rate."
              requires :rate, type: Float, desc: "Rate for each expense."
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
            begin
              arguments = build_arguments
            rescue => error
                     arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            expense = ::Expense.create!(arguments)

            if !expense.errors.empty?
              error = ErrorResponse.new(expense)
              status error.status
              return error.body
            end

            api_response = { 'id' => expense.reload.uuid }.merge!(declared(params))
            api_response
          end

          desc "Validate an expense."

          params do
            use :expense_creation
          end

          post '/validate' do
            begin
                arguments = build_arguments
            rescue => error
              arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            expense = ::Expense.new(arguments)

            if !expense.valid?
              error = ErrorResponse.new(expense)
              status error.status
              return error.body
            end

            status 200
            { valid: true }
          end

        end


      end

    end

  end
end