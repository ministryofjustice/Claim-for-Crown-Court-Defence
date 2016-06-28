module Stats
  class ClaimSubmissionsDataGenerator

    NUM_DAYS_TO_SHOW = 21

    def initialize(date = Date.yesterday)
      @date = date
      @start_date = date - NUM_DAYS_TO_SHOW.days
    end

    def run
      line_graph = Stats::GeckoWidgets::LineGraph.new('Claim Submissions by Type')
      %w{advocate interim litigator transfer}.each do |claim_type|
        add_data_set(line_graph, claim_type)
      end
      line_graph.to_json
    end

    private

    def add_data_set(line_graph, claim_type)
      title = "#{claim_type.capitalize} claims"
      full_claim_type = "Claim::#{claim_type.capitalize}Claim"
      line_graph.add_dataset(title,  Statistic.report('claim_submissions', full_claim_type, @start_date, @date).pluck(:value_1))
    end
  end
end




