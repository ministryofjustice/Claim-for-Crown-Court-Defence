module Stats
  class MoneyClaimedPerMonthDataGenerator

    def initialize(date = Date.yesterday)
      @date = date
    end

    def run
      stats = Statistic.where(report_name: 'money_claimed_per_month').where(date: 1.year.ago..@date).order(:date)
      line_graph = Stats::GeckoWidgets::LineGraph.new
      line_graph.x_axis_labels = stats.pluck(:date).map{ |d| d.strftime('%b %y') }
      line_graph.add_dataset('Claimed (£ millions)', stats.pluck(:value_1).map{ |v| (v / 1_000_000.00).round(2)})
      line_graph
    end

  end
end


