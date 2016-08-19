module Stats
  module Collector
    class ClaimSubmissionsCollector < BaseCollector


      def collect
        count = 0
        [Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim].each do |claim_type|
          count = count_claims(claim_type)
          Statistic.create_or_update(@date, 'claim_submissions', claim_type, count)
        end
        count
      end

      private

      def count_claims(claim_type)
        claim_type.active.where('last_submitted_at between ? and ?', @date.beginning_of_day, @date.end_of_day).count
      end
    end

  end
end