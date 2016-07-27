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
        Statistic.create_or_update(@date, 'redeterminations_average', Claim::BaseClaim, redeterminations_average)
        Statistic.create_or_update(@date, 'claim_submissions_average', Claim::BaseClaim, submissions_average)
      end


      private

      def redeterminations_in_period
        ClaimStateTransition.where(event: 'redetermine', created_at: @rolling_period_start..@rolling_period_end)
      end

      def submissions_in_period
        ClaimStateTransition.where(event: 'submit', created_at: @rolling_period_start..@rolling_period_end)
      end

      def redeterminations
        @redeterminations ||= redeterminations_in_period.group_by { |t| t.created_at.to_date }.values.map(&:size)
      end

      def redeterminations_average
        redeterminations.average(@rolling_period).round
      end

      def submissions
        @submissions ||= submissions_in_period.group_by { |s| s.created_at.to_date }.values.map(&:size)
      end

      def submissions_average
        submissions.average(@rolling_period).round
      end
    end
  end
end
