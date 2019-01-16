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

      def populate_data(total_cost, claim_count)
        @total_cost = total_cost
        @claim_count = claim_count
        raise 'Arguments should be numeric' unless inputs_numeric?
        data = {
          cost_per_transaction_quarter: (@total_cost.to_f / @claim_count.to_f).round(2),
          start_at: @start_date.beginning_of_day.to_s(:db),
          end_at: @start_date.end_of_quarter.end_of_day.to_s(:db),
          total_cost_quarter: @total_cost.to_f,
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

      def inputs_numeric?
        true if Float(@total_cost) && Integer(@claim_count)
      rescue StandardError
        false
      end
    end
  end
end
