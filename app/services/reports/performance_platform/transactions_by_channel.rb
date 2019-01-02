module Reports
  module PerformancePlatform
    class TransactionsByChannel
      attr_reader :ready_to_send

      def initialize(start_date)
        raise 'Report must start on a Monday' unless start_date.monday?
        raise 'Report cannot be in the current week' unless start_date.cweek != Date.today.cweek
        raise 'Report cannot be in the future' unless start_date < Date.today
        @pps = ::PerformancePlatform.report('transactions_by_channel')
        @start_date = start_date
        @ready_to_send = false
      end

      def populate_data
        data = [{ count: 0, channel: 'paper' }]
        data << { count: count_digital_claims, channel: 'digital' }
        data.each do |hash|
          @pps.add_data_set(@start_date, hash)
        end
        @ready_to_send = true
      rescue StandardError
        @ready_to_send = false
      end

      def publish!
        @pps.send_data! if @ready_to_send
      end

      private

      def count_digital_claims
        first = @start_date.beginning_of_day.to_s(:db)
        last = (@start_date + 6.days).end_of_day.to_s(:db)
        Claim::BaseClaim.where(original_submission_date: first..last).count
      end
    end
  end
end
