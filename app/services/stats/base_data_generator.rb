module Stats
  class BaseDataGenerator
    NUM_DAYS_TO_SHOW = 21

    def initialize(date = Date.yesterday)
      @date = date
      @start_date = date - NUM_DAYS_TO_SHOW.days
    end

    def run
      line_graph = Stats::GeckoWidgets::LineGraph.new
      report_types.each do |report_name, description|
        data_series = Statistic.report(report_name, 'Claim::BaseClaim', @start_date, @date).pluck(:value_1)
        line_graph.add_dataset(description, data_series.map) { |v| transform_data_value(v) }
      end
      line_graph
    end

    private

    # define and data transformation in sub class if necessary
    def transform_data_value(value)
      value
    end

    def report_types
      # define in sub class if the run() method in this class is used.
    end
  end
end
