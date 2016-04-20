module API
  module V1
    module ExternalUsers

      class DateAttended < GrapeApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/external_users'
        content_type :json, 'application/json'

        resource :dates_attended, desc: 'Create or Validate' do

          helpers do
            params :date_attended_params do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :api_key, type: String,            desc: "REQUIRED: The API authentication key of the provider"
              optional :attended_item_id, type: String,   desc: 'REQUIRED: The UUID of the corresponding Fee.'
              optional :date, type: String,               desc: 'REQUIRED: The date, or first date in the date-range, applicable to this Fee (YYYY-MM-DD)', standard_json_format: true
              optional :date_to, type: String,            desc: 'OPTIONAL: The last date in the date-range (YYYY-MM-DD)', standard_json_format: true
            end

            # NOTE: explicit error raising because attended_id's presence is
            # not validated by model due to instatiation issues# TODO review in
            # code review
            def validate_attended_item_presence
              attended_item_id = ::Fee::BaseFee.find_by(uuid: params[:attended_item_id]).try(:id)
              if attended_item_id.nil?
                raise API::V1::ArgumentError, 'Attended item cannot be blank'
              end
              attended_item_id
            end

            def build_arguments
              non_date_fields = {
                attended_item_id: validate_attended_item_presence,
                attended_item_type: "Fee::BaseFee"
              }
              args = Hash.new
              args.merge!(non_date_fields).merge_date_fields!([:date, :date_to], params)
              args
            end

          end

          desc "Create a date_attended."

          params do
            use :date_attended_params
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::DateAttended, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

          desc "Validate a date_attended."

          params do
            use :date_attended_params
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::DateAttended, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end
