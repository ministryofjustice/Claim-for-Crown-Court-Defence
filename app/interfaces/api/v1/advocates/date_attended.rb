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

        resource :dates_attended do

          helpers do
            params :date_attended_creation do
              requires :fee_id, type: Integer, desc: 'The ID of the corresponding Fee.'
              requires :date, type: DateTime, desc: 'The date on which this "date_attended" occurred, or the first date in your date-range.'
              optional :date_to, type: DateTime, desc: 'The last date in your date-range'
            end

            def args
              {
                fee_id: params[:fee_id],
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
            ::DateAttended.create!(args)
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
