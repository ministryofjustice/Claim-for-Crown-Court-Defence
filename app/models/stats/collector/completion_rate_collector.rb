module Stats
  module Collector
    class CompletionRateCollector

      COMPLETION_RATE_PERIOD = 28.days

      def initialize(date)
        @date = date
        @start_date = date - COMPLETION_RATE_PERIOD
      end

      def collect
        begin
          num_abandoned = claims_created_at_start_of_period.where(last_submitted_at: nil).count
          num_completed = claims_created_at_start_of_period.where.not(last_submitted_at: nil).count
          num_created = num_abandoned + num_completed
          if num_created == 0
            percentage_completed_e2 = 10000
          else
            percentage_completed_e2 = ((num_completed.to_f / num_created) * 10000).to_i # 0.2546, i.e. 25.46% is stored as 2546
          end
          Statistic.create_or_update(@date, 'completion_percentage', 'Claim::BaseClaim', percentage_completed_e2, num_created)
        rescue => err
          puts "Error processing for date #{@date}"
          puts err.class
          puts err.message
        end

      end

      private

      def claims_created_at_start_of_period
        Claim::BaseClaim.where(created_at: @start_date.beginning_of_day..@start_date.end_of_day)
      end

    end
  end
end