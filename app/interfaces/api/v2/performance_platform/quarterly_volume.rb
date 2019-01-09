module API
  module V2
    module PerformancePlatform
      class QuarterlyVolume < Grape::API
        helpers do
          def report
            Stats::StatsReport.most_recent_by_type('quarterly_volume')
          end

          def quarterly_report
            data = open(report.document_url).read
            JSON.parse(data.gsub(/=>/, ':').gsub(':nil,', ':null,')).deep_symbolize_keys
          end
        end

        resource :performance_platform, desc: 'Performance Platform' do
          resource :quarterly_volume do
            params do
              optional :api_key, type: String, desc: I18n.t('api.v2.generic.params.api_key')
              optional :start_date,
                       type: String,
                       desc: I18n.t('api.v2.performance_platform.quarterly_volume.start_date')
              optional :month_1_usd_value,
                       type: String,
                       desc: I18n.t('api.v2.performance_platform.quarterly_volume.value', month: 'first')
              optional :month_2_usd_value,
                       type: String,
                       desc: I18n.t('api.v2.performance_platform.quarterly_volume.value', month: 'second')
              optional :month_3_usd_value,
                       type: String,
                       desc: I18n.t('api.v2.performance_platform.quarterly_volume.value', month: 'third')
            end

            desc 'Calculate totals for quarterly volume performance platform report'
            get do
              options = {
                quarter_start: params[:start_date],
                month_1: params[:month_1_usd_value],
                month_2: params[:month_2_usd_value],
                month_3: params[:month_3_usd_value]
              }
              Stats::StatsReportGenerator.call('quarterly_volume', options)

              present quarterly_report
            end
          end

          resource :quarterly_volume do
            params do
              optional :api_key, type: String, desc: I18n.t('api.v2.generic.params.api_key')
              optional :start_date,
                       type: String,
                       desc: I18n.t('api.v2.performance_platform.quarterly_volume.start_date')
            end
            desc 'Submit calculated totals for quarterly volume performance platform report'
            post do
              results = quarterly_report
              start_of_quarter = Date.parse(results[:month_one][:date]).beginning_of_month
              qvr = Reports::PerformancePlatform::QuarterlyVolume.new(start_of_quarter)
              qvr.populate_data(results[:total_quarter_cost])
              published = qvr.publish!
              result = { successful_upload: JSON.parse(published)['status'] }
              report.destroy
              present result.as_json
            end
          end
        end
      end
    end
  end
end
