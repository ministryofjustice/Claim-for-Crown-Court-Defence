module Stats
  module Collector
    # class to work out the rolling average of time from reject to authorize
    class TimeFromRejectToAuthCollector < BaseCollector
      def initialize(date = Date.today)
        super
        @rolling_period_start = (@date - rolling_average_period).beginning_of_day
        @rolling_period_end = @date.end_of_day
      end

      def collect
        claim_ids = authorised_cloned_claims.pluck(:id)
        claim_count = claim_ids.size
        period_total = 0
        claim_ids.each do |claim_id|
          period_total += days_reject_to_auth(claim_id)
        end
        avg = claim_count.zero? ? 0 : period_total / claim_count
        Statistic.create_or_update(@date, 'time_reject_to_auth', 'Claim::BaseClaim', avg, claim_count)
      end

      private

      def rolling_average_period
        7.days
      end

      def authorised_cloned_claims
        claims_authorised_in_rolling_average_period.where.not(clone_source_id: nil)
      end

      def claims_authorised_in_rolling_average_period
        Claim::BaseClaim.active.where('authorised_at between ? and ?', @rolling_period_start, @rolling_period_end)
      end

      def days_reject_to_auth(claim_id)
        cloned_claim = Claim::BaseClaim.active.find claim_id
        source_claim = Claim::BaseClaim.active.find cloned_claim.clone_source_id
        cloned_claim.authorised_at - rejected_date_for(source_claim)
      end

      def rejected_date_for(claim)
        reject_transition = claim.claim_state_transitions.detect { |cst| cst.to == 'rejected' }
        reject_transition.created_at
      end
    end
  end
end
