module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Defendant < Grape::API

        include ApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :defendants, desc: 'Create or Validate' do

          helpers do
            params :defendant_creation do
              optional :claim_id, type: String,         desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
              optional :first_name, type: String,       desc: "REQUIRED: First name of the defedant."
              optional :middle_name, type: String,      desc: "OPTIONAL: Middle name of the defendant."
              optional :last_name, type: String,        desc: "REQUIRED: Last name of the defendant."
              optional :date_of_birth, type: DateTime,  desc: "REQUIRED: Defendant's date of birth (YYYY/MM/DD)."
              optional :order_for_judicial_apportionment, type: Boolean, desc: "OPTIONAL: whether or not the defendant is impacted by an order for judicial apportionment"
            end

            def build_arguments
              {
                claim_id:       ::Claim.find_by(uuid: params[:claim_id]).try(:id),
                first_name:     params[:first_name],
                middle_name:    params[:middle_name],
                last_name:      params[:last_name],
                date_of_birth:  params[:date_of_birth],
                order_for_judicial_apportionment: params[:order_for_judicial_apportionment]
              }
            end

          end

          desc "Create a defendant."

          params do
            use :defendant_creation
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Defendant, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a defendant."

          params do
            use :defendant_creation
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Defendant, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end
