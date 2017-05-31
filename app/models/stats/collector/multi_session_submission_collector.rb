module Stats
  module Collector
    class MultiSessionSubmissionCollector < BaseCollector
      def collect
        num_single_session_submissions = submitted_claims_for_day.where(last_edited_at: nil).count
        Statistic.create_or_update(@date, 'single_session_submissions', 'Claim::BaseClaim', num_single_session_submissions)
        num_multi_session_submissions = submitted_claims_for_day.where.not(last_edited_at: nil).count
        Statistic.create_or_update(@date, 'multi_session_submissions', Claim::BaseClaim, num_multi_session_submissions)
      end

      private

      def submitted_claims_for_day
        Claim::BaseClaim.active.where('last_submitted_at between ? and ?', @date.beginning_of_day, @date.end_of_day)
      end
    end
  end
end
