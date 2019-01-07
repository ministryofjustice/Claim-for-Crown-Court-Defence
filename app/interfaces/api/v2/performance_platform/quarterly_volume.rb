module API
  module V2
    module PerformancePlatform
      class QuarterlyVolume < Grape::API
        resource :performance_platform, desc: 'Performance Platform' do
          resource :quarterly_volume do
            desc 'Calculate totals for quarterly volume performance platform report'
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
            get do
              # create stats_report record then display it
              # this can be deleted by a successful post
              # or replaced by a re-generation of this end point
              results = {
                month_one: {
                  date: params[:start_date],
                  usd_value: params[:month_1_usd_value],
                  gbp_value: '00.00'
                },
                month_two: {
                  date: params[:start_date].to_date + 1.month,
                  usd_value: params[:month_2_usd_value],
                  gbp_value: '00.00'
                },
                month_three: {
                  date: Date.parse(params[:start_date]) + 2.months,
                  usd_value: params[:month_3_usd_value],
                  gbp_value: '00.00'
                },
                total_quarter_cost: '00.00',
                claim_count: '0000',
                cost_per_transaction_quarter: '00.00'
              }
              present JSON.parse(results.to_json)
            end
          end
        end
      end
    end
  end
end
