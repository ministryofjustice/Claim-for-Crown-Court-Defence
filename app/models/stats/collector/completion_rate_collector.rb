module Stats
  module Collector
    class CompletionRateCollector
      COMPLETION_RATE_PERIOD = 28.days

      def initialize(date)
        @date = date
        @start_date = date - COMPLETION_RATE_PERIOD
      end

      def collect
        form_ids_created_at_period_start = ClaimIntention
                                           .where(created_at: @start_date.all_day)
                                           .pluck(:form_id)
        num_started = form_ids_created_at_period_start.size
        num_completed = Claim::BaseClaim
                        .active
                        .where(form_id: form_ids_created_at_period_start)
                        .where.not(last_submitted_at: nil)
                        .count
        # 0.2546, i.e. 25.46% is stored as 2546
        percentage_completed_e2 = num_started.zero? ? 1000 : ((num_completed.to_f / num_started) * 10_000).to_i
        Statistic.create_or_update(@date,
                                   'completion_percentage',
                                   'Claim::BaseClaim',
                                   percentage_completed_e2,
                                   num_completed)
      rescue StandardError => e
        puts "Error processing for date #{@date}"
        puts e.class
        puts e.message
      end
    end
  end
end
