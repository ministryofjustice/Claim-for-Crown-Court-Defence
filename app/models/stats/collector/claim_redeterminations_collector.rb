module Stats
  module Collector
    class ClaimRedeterminationsCollector < BaseCollector

      def initialize(date = Date.today)
        super
        @rolling_period = 7
        @rolling_period_start = (@date - @rolling_period.days).beginning_of_day
        @rolling_period_end = @date.end_of_day
      end

      def collect
        Statistic.create_or_update(@date, 'redeterminations_average', Claim::BaseClaim, average, total)
      end


      private

      def redeterminations_in_period
        ClaimStateTransition.where(event: 'redetermine', created_at: @rolling_period_start..@rolling_period_end)
      end

      def redeterminations
        @redeterminations ||= redeterminations_in_period.group_by { |t| t.created_at.day }.values.map(&:size)
      end

      def average
        redeterminations.average(@rolling_period).round
      end

      def total
        redeterminations.sum
      end
    end
  end
end
