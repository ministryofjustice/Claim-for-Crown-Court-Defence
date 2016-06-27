module Stats
  class ClaimSubmissionsDataGenerator

    def initialize(date = Date.yesterday)
      @date = date
    end

    def run
      line_graph = Stats::GeckoWidgets::LineGraph.new('Claim Submissions by Type')
      line_graph.add_dataset('Advocate Claims', Statistic.report('claim_submissions', 'Claim::AdvocateClaim', @date - 21.days, @date).pluck(:value_1))
      line_graph.add_dataset('Interim Claims', Statistic.report('claim_submissions', 'Claim::InterimClaim', @date - 21.days, @date).pluck(:value_1))
      line_graph.add_dataset('Litigator Claims', Statistic.report('claim_submissions', 'Claim::LitigatorClaim', @date - 21.days, @date).pluck(:value_1))
      line_graph.add_dataset('Transfer Claims', Statistic.report('claim_submissions', 'Claim::TransferClaim', @date - 21.days, @date).pluck(:value_1))
      line_graph.to_json
    end
  end
end




