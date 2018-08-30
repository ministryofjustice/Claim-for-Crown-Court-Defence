module API
  module V2
    module MI
      class ProvisionalAssessments < Grape::API
        require 'csv'
        helpers API::V2::MIHelper

        content_type :csv, 'text/csv; utf-8'
        default_format :json

        resource :mi, desc: 'MI endpoint' do
          resource :provisional_assessments do
            helpers do
              def date_range
                @start_date = params[:start_date].to_date.beginning_of_day.utc
                @end_date = params[:end_date].to_date.end_of_day.utc
                { start_date: @start_date, end_date: @end_date }
              rescue NoMethodError
                error!('Please provide both dates in the format YYYY-MM-DD', 400)
              end
            end

            desc 'Retrieve provisional assessment data from between two dates'
            params do
              optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
              optional :start_date, type: String, desc: 'REQUIRED: Claims submitted on or after date (YYYY-MM-DD).'
              optional :end_date, type: String, desc: 'REQUIRED: Claims submitted on or before date (YYYY-MM-DD).'
              optional :format, type: String, desc: 'JSON or CSV. Defaults to JSON', values: %w[json csv]
            end
            get do
              results = Reports::ProvisionalAssessmentsByDates.call(date_range)
              if params[:format].eql?('csv')
                csv = build_csv_from(results, Reports::ProvisionalAssessmentsByDates::COLUMNS)
                filename = "attachment; filename=provisional-assessment-#{params[:start_date]}-#{params[:end_date]}.csv"
                header 'Content-Disposition', filename
                present csv
              else
                present JSON.parse(results.to_json, object_class: OpenStruct),
                        with: API::Entities::ProvisionalAssessment
              end
            end
          end
        end
      end
    end
  end
end
