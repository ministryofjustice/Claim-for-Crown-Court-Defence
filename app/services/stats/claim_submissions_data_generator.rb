module Stats
  class ClaimSubmissionsDataGenerator < BaseDataGenerator
    NUM_DAYS_TO_SHOW = 21

    CLAIM_TYPES = {
      'Claim::AdvocateClaim' => 'Advocate',
      'Claim::InterimClaim' => 'Litigator interim',
      'Claim::LitigatorClaim' => 'Litigator final',
      'Claim::TransferClaim' => 'Litigator transfer'
    }.freeze

    def initialize(date = Date.yesterday)
      @date = date
      @start_date = date - NUM_DAYS_TO_SHOW.days
    end

    def run
      line_graph = Stats::GeckoWidgets::LineGraph.new
      CLAIM_TYPES.each do |claim_type, description|
        line_graph.add_dataset(description,
                               Statistic.report('claim_submissions', claim_type, @start_date, @date).pluck(:value_1))
      end
      line_graph
    end
  end
end
