module API
  module V1
    module ExternalUsers

      class Defendant < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :defendants, desc: 'Create or Validate' do

          helpers do

            params :defendant_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,                            desc: "REQUIRED: The API authentication key of the provider"
              optional :claim_id, type: String,                           desc: "REQUIRED: Unique identifier for the claim associated with this defendant."
              optional :first_name, type: String,                         desc: "REQUIRED: First name of the defedant."
              optional :last_name, type: String,                          desc: "REQUIRED: Last name of the defendant."
              optional :date_of_birth, type: String,                      desc: "REQUIRED: Defendant's date of birth (YYYY-MM-DD).", standard_json_format: true
              optional :order_for_judicial_apportionment, type: Boolean,  desc: "OPTIONAL: whether or not the defendant is impacted by an order for judicial apportionment (JSON Boolean data type: true or false)"
            end

            def build_arguments
              non_date_fields = {
                claim_id:       ::Claim::BaseClaim.find_by(uuid: params[:claim_id]).try(:id),
                first_name:     params[:first_name],
                last_name:      params[:last_name],
                order_for_judicial_apportionment: params[:order_for_judicial_apportionment]
              }
              args = Hash.new
              args.merge!(non_date_fields).merge_date_fields!([:date_of_birth], params)
              args
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
