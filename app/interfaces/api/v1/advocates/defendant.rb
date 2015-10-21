module API
  module V1
    module Advocates

      class Defendant < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :defendants, desc: 'Create or Validate' do

          helpers do
            include ExtractDate

            params :defendant_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,                            desc: "REQUIRED: The API authentication key of the chamber"
              optional :claim_id, type: String,                           desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
              optional :first_name, type: String,                         desc: "REQUIRED: First name of the defedant."
              optional :last_name, type: String,                          desc: "REQUIRED: Last name of the defendant."
              optional :date_of_birth, type: String,                      desc: "REQUIRED: Defendant's date of birth (YYYY-MM-DD).", standard_json_format: true
              optional :order_for_judicial_apportionment, type: Boolean,  desc: "OPTIONAL: whether or not the defendant is impacted by an order for judicial apportionment"
            end

            def build_arguments
              {
                claim_id:       ::Claim.find_by(uuid: params[:claim_id]).try(:id),
                first_name:     params[:first_name],
                last_name:      params[:last_name],
                date_of_birth_dd:    extract_date(:day, params[:date_of_birth]),
                date_of_birth_mm:    extract_date(:month, params[:date_of_birth]),
                date_of_birth_yyyy:  extract_date(:year, params[:date_of_birth]),
                order_for_judicial_apportionment: params[:order_for_judicial_apportionment]
              }
            end

          end

          desc "Create a defendant."

          params do
            use :defendant_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::Defendant, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a defendant."

          params do
            use :defendant_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::Defendant, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end
