module Reports
  module PerformancePlatform
    class TransactionsByChannel
      attr_reader :ready_to_send

      def initialize(start_date)
        @start_date = start_date
        raise 'Report must start on a Monday' unless @start_date.monday?
        raise 'Report cannot be in the current week' if @start_date.cweek.eql?(Date.today.cweek)
        raise 'Report cannot be in the future' if @start_date >= Date.today
        @pps = ::PerformancePlatform.report('transactions_by_channel')
        @ready_to_send = false
      end

      def populate_data
        data = [{ count: 0, channel: 'Paper' }]
        data << { count: count_digital_claims, channel: 'Digital' }
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
        @count_digital_claims ||= Claims::Count.week(@start_date)
      end
    end
  end
end
