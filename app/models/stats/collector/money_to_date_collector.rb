module Stats
  module Collector
    class MoneyToDateCollector < BaseCollector

      def initialize(date)
        super
        @total = 0
        @num_assessments = 0
      end

      def collect
        total_money_to_date_inc_vat = Claim::BaseClaim.active.where.not(state: 'draft').where(clone_source_id: nil).pluck(:total, :vat_amount).flatten.sum
        num_claims = Claim::BaseClaim.active.where.not(state: 'draft').where(clone_source_id: nil).count
        Statistic.create_or_update(@date, "money_to_date", Claim::BaseClaim, total_money_to_date_inc_vat, num_claims)
      end
    end
  end
end


