module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Defendant < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :defendants, desc: 'Create or Validate' do

          helpers do
            params :defendant_creation do
              requires :claim_id, type: String, desc: "Unique identifier for the claim associated with this defendant."
              requires :first_name, type: String, desc: "First name of the defedant."
              optional :middle_name, type: String, desc: "Middle name of the defendant."
              requires :last_name, type: String, desc: "Last name of the defendant."
              requires :date_of_birth, type: DateTime, desc: "Defendant's date of birth (YYYY/MM/DD)."
              optional :order_for_judicial_apportionment, type: Boolean
            end

            def build_arguments
              {
                claim_id: ::Claim.find_by(uuid: params[:claim_id]).try(:id),
                first_name: params[:first_name],
                middle_name: params[:middle_name],
                last_name: params[:last_name],
                date_of_birth: params[:date_of_birth],
                order_for_judicial_apportionment: params[:order_for_judicial_apportionment]
              }
            end

          end

          desc "Create a defendant."

          params do
            use :defendant_creation
          end

          post do
            begin
              arguments = build_arguments
            rescue => error
                     arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            defendant = ::Defendant.create!(arguments)

            if !defendant.errors.empty?
              error = ErrorResponse.new(defendant)
              status error.status
              return error.body
            end

            api_response = { 'id' => defendant.reload.uuid }.merge!(declared(params))
            api_response
          end

          desc "Validate a defendant."

          params do
            use :defendant_creation
          end

          post '/validate' do

            begin
                arguments = build_arguments
            rescue => error
              arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            defendant = ::Defendant.new(arguments)

            if !defendant.valid?
              error = ErrorResponse.new(defendant)
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
