module Stats
  class RequestForFurtherInfoDataGenerator

    NUM_DAYS_TO_SHOW = 21

    SUBMISSION_TYPES = {
      'claims_authorised_after_info_requested' => 'requested',
      'claims_authorised_without_further_info' => 'not requested'
    }


    def initialize(date = Date.yesterday)
      @date = date
      @start_date = date - NUM_DAYS_TO_SHOW.days
    end

    def run
      line_graph = Stats::GeckoWidgets::LineGraph.new

      SUBMISSION_TYPES.each do |report_name, description|
        line_graph.add_dataset(description,  Statistic.report(report_name, 'Claim::BaseClaim', @start_date, @date).pluck(:value_1))
      end
      line_graph.to_json
    end
  end
end