module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class DateAttended < Grape::API

        include ApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :dates_attended, desc: 'Create or Validate' do

          helpers do
            params :date_attended_creation do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :attended_item_id, type: String,   desc: 'REQUIRED: The ID of the corresponding Fee or Expense.'
              optional :attended_item_type, type: String, desc: 'REQUIRED: The Type of item to which this date range relates - Fee or Expense.'
              optional :date, type: DateTime,             desc: 'REQUIRED: The date, or first date in the date-range, applicable to this Fee (YYYY/MM/DD)'
              optional :date_to, type: DateTime,          desc: 'The last date your date-range (YYYY/MM/DD)'
            end

            def build_arguments
              attended_item_type_class = "::#{params[:attended_item_type].capitalize}".constantize
              attended_item_id = attended_item_type_class.find_by(uuid: params[:attended_item_id]).try(:id)

              # TODO review in code review
              # NOTE: explicit error raising because attended_id's presence is not validated by model due to instatiation issues
              if attended_item_id.nil?
                raise API::V1::ArgumentError, 'Attended item can\'t be blank'
              end

              {
                attended_item_id: attended_item_id,
                attended_item_type:  params[:attended_item_type].capitalize,
                date: params[:date],
                date_to: params[:date_to],
              }
            end

          end

          desc "Create a date_attended."

          params do
            use :date_attended_creation
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::DateAttended, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end


          desc "Validate a date_attended."

          params do
            use :date_attended_creation
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::DateAttended, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end

        end


      end

    end

  end
end
