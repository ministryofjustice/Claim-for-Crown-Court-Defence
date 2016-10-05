module API
  module V1
    module ExternalUsers

      class DateAttended < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
          optional :attended_item_id, type: String, desc: 'REQUIRED: The UUID of the corresponding Fee.'
          optional :date, type: String, desc: 'REQUIRED: The date, or first date in the date-range, applicable to this Fee (YYYY-MM-DD)', standard_json_format: true
          optional :date_to, type: String, desc: 'OPTIONAL: The last date in the date-range (YYYY-MM-DD)', standard_json_format: true
        end

        resource :dates_attended, desc: 'Create or Validate' do
          helpers do
            def attended_item_id
              ::Fee::BaseFee.find_by(uuid: params[:attended_item_id]).try(:id) || (raise ArgumentError, 'Attended item cannot be blank')
            end

            def build_arguments
              declared_params.merge(attended_item_id: attended_item_id, attended_item_type: 'Fee::BaseFee')
            end
          end

          desc 'Create a date_attended.'
          post do
            create_resource(::DateAttended)
            status api_response.status
            api_response.body
          end

          desc 'Validate a date_attended.'
          post '/validate' do
            validate_resource(::DateAttended)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
