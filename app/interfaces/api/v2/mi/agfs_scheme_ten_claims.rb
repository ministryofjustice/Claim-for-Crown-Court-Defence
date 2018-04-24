module API
  module V2
    module MI
      class AGFSSchemeTenClaims < Grape::API
        require 'csv'
        helpers Claims::MI::Queries
        helpers API::V2::MIHelper

        content_type :csv, 'text/csv; utf-8'
        default_format :json

        resource :mi, desc: 'MI endpoint' do
          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            optional :date, type: String, desc: 'OPTIONAL: the date of the rep order (YYYY-MM-DD)'
            optional :format, type: String, desc: I18n.t('api.v2.mi.scheme_ten.format'), values: %w[json csv]
          end

          helpers do
            def claims
              start_date, end_date = start_and_end_from(params[:date])
              @claims ||= ActiveRecord::Base.connection.execute(scheme_ten_claims(start_date, end_date)).to_a
            end
          end

          resource :scheme_10_claims do
            desc 'Retrieve claims created with a scheme 10 rep order'
            get do
              if params[:format].eql?('csv')
                records = claims.count.zero? ? [{ 'No scheme ten claims filed on' => params[:date] }] : claims
                csv = build_csv_from(records)
                header 'Content-Disposition', "attachment; filename=scheme_ten_data-#{params[:date]}.csv"
                present csv
              else
                object, entity = claims.count.positive? ? [nil, nil] : [OpenStruct, API::Entities::AGFSSchemeTen::Claim]
                present JSON.parse(claims.to_json, object_class: object), with: entity
              end
            end
          end
        end
      end
    end
  end
end
