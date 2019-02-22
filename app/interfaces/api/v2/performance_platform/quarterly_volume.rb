module API
  module V2
    module PerformancePlatform
      class QuarterlyVolume < Grape::API
        helpers do
          def quarterly_report_data(filename)
            data = File.open(filename, 'r').read
            JSON.parse(data.gsub(/=>/, ':').gsub(':nil,', ':null,')).deep_symbolize_keys
          rescue StandardError
            error!('No report exists', 400)
          end

          def filename(start_date)
            File.join(Rails.root, 'tmp', "#{start_date.strftime('%Y_%m')}_qv_report.json")
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
              # Stats::StatsReportGenerator.call('quarterly_volume', options)
              quarterly_report = Stats::QuarterlyVolumeGenerator.call(options)
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
              start_of_quarter = Time.parse(params[:start_date]).beginning_of_quarter
              filename = filename(start_of_quarter)
              results = quarterly_report_data(filename)
              qvr = Reports::PerformancePlatform::QuarterlyVolume.new(start_of_quarter)
              qvr.populate_data(results[:total_quarter_cost], results[:claim_count])
              published = qvr.publish!
              result = { successful_upload: JSON.parse(published)['status'] }
              File.delete(filename)
              present result.as_json
            end
          end
        end
      end
    end
  end
end
