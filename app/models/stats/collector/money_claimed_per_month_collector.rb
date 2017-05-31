module Stats
  module Collector
    class MoneyClaimedPerMonthCollector < BaseCollector
      def initialize(date = Date.today)
        super
        @date = @date.end_of_month
        @period_start = @date.beginning_of_month.beginning_of_day
        @period_end = @date.end_of_month.end_of_day
        @total_value = 0
        @num_claims = 0
      end

      def collect
        generate_data
        Statistic.create_or_update(@date, 'money_claimed_per_month', Claim::BaseClaim, @total_value.to_i, @num_claims)
      end

      private

      def generate_data
        @total_value = submitted_claims_this_period.pluck(:total, :vat_amount).flatten.sum
        @num_claims = submitted_claims_this_period.count
      end

      def submitted_claims_this_period
        Claim::BaseClaim.active.where(last_submitted_at: @period_start..@period_end)
      end
    end
  end
end
