module Reports
  module PerformancePlatform
    class QuarterlyVolume
      attr_reader :ready_to_send

      def initialize(start_date)
        raise 'Report must start on a quarter' unless start_date.at_beginning_of_quarter.eql?(start_date)
        raise 'Report cannot be in the future' unless start_date < Date.today
        @pps = ::PerformancePlatform.report('quarterly_volumes')
        @start_date = start_date
        @ready_to_send = false
      end

      def populate_data
        @total_cost = total_cost.to_f
        @claim_count = count_digital_claims
        raise 'Arguments should be numeric' unless inputs_numeric?
        data = {
          cost_per_transaction_quarter: @total_cost.fdiv(@claim_count).round(2),
          start_at: @start_date.beginning_of_day.to_s(:db),
          end_at: @start_date.end_of_quarter.end_of_day.to_s(:db),
          total_cost_quarter: @total_cost,
          transactions_per_quarter: @claim_count
        }
        @pps.add_data_set(@start_date, data)
        @ready_to_send = true
        @pps.data_sets
      rescue RuntimeError => e
        raise e
      rescue StandardError
        @ready_to_send = false
      end

      def publish!
        @pps.send_data! if @ready_to_send
      end

      private

      def total_cost
        usd_costs = extract_aws_costs
        gbp_costs = usd_costs.results_by_time.map do |month|
          Conversion::Currency.call(Date.parse(month.time_period.end) - 1.day, month.total['UnblendedCost'].amount)
        end
        gbp_costs.sum.to_s
      end

      def extract_aws_costs
        client.get_cost_and_usage(
          time_period: {
            start: @start_date.to_s(:db),
            end: (@start_date.end_of_quarter + 1.day).to_s(:db)
          },
          granularity: 'MONTHLY',
          filter: {
            dimensions: {
              key: 'LINKED_ACCOUNT',
              values: [aws_linked_account_name]
            }
          },
          metrics: ['UNBLENDED_COST']
        )
      end

      def aws_linked_account_name
        response = client.get_dimension_values(
          time_period: {
            start: @start_date.to_s(:db),
            end: (@start_date.end_of_quarter + 1.day).to_s(:db)
          },
          dimension: 'LINKED_ACCOUNT',
          context: 'COST_AND_USAGE',
          search_string: Settings.aws.billing.account
        )
        JSON.parse(response.data.to_json)['dimension_values'].first['value']
      end

      def count_digital_claims
        @count_digital_claims ||= Claims::Count.quarter(@start_date)
      end

      def client
        @client ||= Aws::CostExplorer::Client.new(access_key_id: Settings.aws.billing.access,
                                                  secret_access_key: Settings.aws.billing.secret,
                                                  region: 'us-east-1')
      end

      def inputs_numeric?
        true if Float(@total_cost) && Integer(@claim_count)
      rescue StandardError
        false
      end
    end
  end
end
