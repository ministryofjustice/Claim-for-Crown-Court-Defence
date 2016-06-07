module API
  module V1
    module ExternalUsers
      class RepresentationOrder < GrapeApiHelper
        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :representation_orders, desc: 'Create or Validate' do
          helpers do
            # include ExtractDate
            # include API::V1::ApiHelper

            params :representation_order_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,                    desc: "REQUIRED: The API authentication key of the provider"
              optional :defendant_id, type: String,               desc: 'REQUIRED: ID of the defendant'
              optional :maat_reference, type: String,             desc: "REQUIRED: The unique identifier for this representation order"
              optional :representation_order_date, type: String,  desc: "REQUIRED: The date on which this representation order was granted (YYYY-MM-DD)", standard_json_format:true
            end

            # NOTE: explicit error raising because defendant_id's presence is not validated by model due to instatiation issues # TODO review in code review
            def validate_defendant_presence
              defendant_id = ::Defendant.find_by(uuid: params[:defendant_id]).try(:id)
              if defendant_id.nil?
                raise API::V1::ArgumentError, 'Defendant cannot be blank'
              end
              defendant_id
            end

            def build_arguments
              defendant_id = validate_defendant_presence
              non_date_fields = {
                defendant_id: defendant_id,
                maat_reference: params[:maat_reference]
              }
              args = Hash.new
              args.merge!(non_date_fields).merge_date_fields!([:representation_order_date], params)
              args
            end
          end

          desc "Create a representation_order."

          params do
            use :representation_order_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::RepresentationOrder, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end


          desc "Validate a representation_order."

          params do
            use :representation_order_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::RepresentationOrder, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end
        end
      end
    end
  end
end