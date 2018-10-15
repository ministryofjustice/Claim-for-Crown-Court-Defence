module API
  module V2
    module MI
      class AdditionalInformationExpenses < Grape::API
        require 'csv'
        helpers API::V2::MIHelper

        content_type :csv, 'text/csv; utf-8'
        default_format :json

        resource :mi, desc: 'MI endpoint' do
          resource :additional_travel_expense_information do
            helpers do
              def date_range
                @start_date = params[:start_date].to_date.beginning_of_day.utc
                @end_date = params[:end_date].to_date.end_of_day.utc
                { start_date: @start_date, end_date: @end_date }
              rescue NoMethodError
                error!('Please provide both dates in the format YYYY-MM-DD', 400)
              end
            end

            desc 'Retrieve additional travel expenses information from between two dates'
            params do
              optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
              optional :start_date, type: String, desc: 'REQUIRED: Claims submitted on or after date (YYYY-MM-DD).'
              optional :end_date, type: String, desc: 'REQUIRED: Claims submitted on or before date (YYYY-MM-DD).'
              optional :format, type: String, desc: 'JSON or CSV. Defaults to JSON', values: %w[json csv]
            end
            get do
              results = Reports::AdditionalTravelExpenseInformationByDates.call(date_range)
              if params[:format].eql?('csv')
                csv = build_csv_from(results, Reports::AdditionalTravelExpenseInformationByDates::COLUMNS)
                filename = "travel-expense-information-#{params[:start_date]}-#{params[:end_date]}"
                header 'Content-Disposition', "attachment; filename=#{filename}.csv"
                present csv
              else
                present JSON.parse(results.to_json, object_class: OpenStruct),
                        with: API::Entities::AdditionalTravelExpenseInformation
              end
            end
          end
        end
      end
    end
  end
end
