module API
  module V1


    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class DateAttended < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :dates_attended, desc: 'Create or Validate' do

          helpers do
            params :date_attended_creation do
              requires :attended_item_id, type: String, desc: 'The ID of the corresponding Fee or Expense.'
              requires :attended_item_type, type: String, desc: 'The Type of item to which this date range relates - Fee or Expense.'
              requires :date, type: DateTime, desc: 'The date, or first date in the date-range, applicable to this Fee (YYYY/MM/DD)'
              optional :date_to, type: DateTime, desc: 'The last date your date-range (YYYY/MM/DD)'
            end

            def args
              attended_item_type_class = "::#{params[:attended_item_type].capitalize}".constantize
              attended_item_id = attended_item_type_class.find_by(uuid: params[:attended_item_id]).try(:id)

              {
                attended_item_id: attended_item_id,
                attended_item_type:  params[:attended_item_type].capitalize,
                date: params[:date],
                date_to: params[:date_to]
              }
            end

          end

          desc "Create a date_attended."

          params do
            use :date_attended_creation
          end

          post do
            date_attended = ::DateAttended.create!(args)
            api_response = { 'id' => date_attended.reload.uuid }.merge!(declared(params))
            api_response
          end


          desc "Validate a date_attended."

          params do
            use :date_attended_creation
          end

          post '/validate' do
            date_attended = ::DateAttended.new(args)

            if !date_attended.valid?
                    error = ErrorResponse.new(date_attended)
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
