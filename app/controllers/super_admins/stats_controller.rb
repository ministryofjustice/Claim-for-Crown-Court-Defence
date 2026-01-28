module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show

    def show
      @chart_colours = %w[#ffdd00 #00703c #5694ca #912b88 #f47738 #85994b #003078 #f499be #b52c17 #ea7361 #66ff66
                          #00b2a9 #8c564b #666666 #ff6f91 #2ca02c]
      set_times
      generate_graph_data
    end

    private

    def generate_graph_data
      graph_data = Stats::Graphs::VariablePeriod.new(from: @from, to: @to)
      line_data = Stats::Graphs::SixMonthPeriod.new

      @total_claims = graph_data.call(&:count)
      @total_values = graph_data.call do |claims|
        claims.sum { |claim| claim.total + claim.vat_amount }.round(2)
      end
      @six_month_breakdown = line_data.call

      @graph_title = graph_data.title
      @line_title = line_data.title
      @date_err = graph_data.date_err
    end

    def parse_time(date)
      Time.zone.parse("#{params["#{date}(3i)"]}-#{params["#{date}(2i)"]}-#{params["#{date}(1i)"]}")
    end

    def set_times
      @from = parse_time('date_from') || Time.current.at_beginning_of_month
      @to = parse_time('date_to')
    end
  end
end
