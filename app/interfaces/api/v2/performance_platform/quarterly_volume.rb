module API
  module V2
    module PerformancePlatform
      class QuarterlyVolume < Grape::API
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
              results = Stats::QuarterlyVolumeGenerator.call(options)
              present JSON.parse(results.content.gsub(/=>/, ':').gsub(':nil,', ':null,'))
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
              # load results from tmp/s3
              # error if previously generated files have not been saved
              # parse results
              # send results
              result = { successful_upload: true }
              present result.as_json
            end
          end
        end
      end
    end
  end
end
