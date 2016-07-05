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
          form_ids_created_at_period_start = ClaimIntention.where(created_at: @start_date.beginning_of_day..@start_date.end_of_day).pluck(:form_id)
          num_started = form_ids_created_at_period_start.size
          num_completed = Claim::BaseClaim.where(form_id: form_ids_created_at_period_start).where.not(last_submitted_at: nil).count
          if num_started == 0
            percentage_completed_e2 = 10000
          else
            percentage_completed_e2 = ((num_completed.to_f / num_started) * 10000).to_i # 0.2546, i.e. 25.46% is stored as 2546
          end
          Statistic.create_or_update(@date, 'completion_percentage', 'Claim::BaseClaim', percentage_completed_e2, num_completed)
        rescue => err
          puts "Error processing for date #{@date}"
          puts err.class
          puts err.message
        end

      end

    end
  end
end