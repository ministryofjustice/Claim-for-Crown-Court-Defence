module API
  module V2
    module MI
      class InjectionErrors < Grape::API
        require 'csv'
        helpers API::V2::MIHelper

        content_type :csv, 'text/csv; utf-8'
        default_format :json

        resource :mi, desc: 'MI endpoint' do
          resource :injection_errors do
            helpers do
              def date_range
                hash = { start_date: 1.day.ago.utc.beginning_of_day, end_date: 1.day.ago.utc.end_of_day }
                return hash unless params[:date].present?
                hash[:start_date] = params[:date].to_date.beginning_of_day.utc
                hash[:end_date] = params[:date].to_date.end_of_day.utc
                hash
              end
            end

            desc 'Retrieve totals for injection error categories'
            params do
              optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
              optional :date, type: String, desc: 'OPTIONAL: Occurence Date (YYYY-MM-DD). Defaults to yesterday'
              optional :format, type: String, desc: 'JSON or CSV. Defaults to JSON', values: %w[json csv]
            end
            get do
              results = Reports::InjectionErrors.call(date_range)
              if params[:format].eql?('csv')
                csv = build_csv_from(results, Reports::InjectionErrors::COLUMNS)
                header 'Content-Disposition', "attachment; filename=injection_errors_categories-#{params[:date]}.csv"
                present csv
              else
                present JSON.parse(results.to_json, object_class: OpenStruct),
                        with: API::Entities::InjectionErrorCategory
              end
            end
          end
        end
      end
    end
  end
end
