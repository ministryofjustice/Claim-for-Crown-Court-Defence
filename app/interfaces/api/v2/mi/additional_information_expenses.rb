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
                default_hash = { start_date: 1.day.ago.utc.beginning_of_day, end_date: 1.day.ago.utc.end_of_day }
                return default_hash unless params[:start_date].present?
                @start_date = params[:start_date].to_date.beginning_of_day.utc
                @end_date = params[:end_date].to_date.end_of_day.utc
                { start_date: @start_date, end_date: @end_date }
              rescue NoMethodError, ArgumentError
                error!('Please provide both dates in the format YYYY-MM-DD', 400)
              end
            end

            desc 'Retrieve additional travel expenses information from between two dates'
            params do
              optional :api_key, type: String, desc: I18n.t('api.v2.generic.params.api_key')
              optional :start_date, type: String, desc: I18n.t('api.v2.mi.travel_automation.date_from')
              optional :end_date, type: String, desc: I18n.t('api.v2.mi.travel_automation.date_to')
              optional :format, type: String, desc: I18n.t('api.v2.generic.params.format'), values: %w[json csv]
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
