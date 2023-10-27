module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show

    def show
      @chart_colours = %w[#ffdd00	#00703c #5694ca #912b88 #f47738 #85994b #003078 #f499be #b52c17 #ea7361 #66ff66]
      set_times
      generate_six_month_breakdown

      graph_data = Stats::Graphs::Simple.new(from: @from, to: @to)
      @total_claims = graph_data.call { |claims| claims.count }

      @total_values = graph_data.call do |claims|
        claims.sum { |claim| claim.total + claim.vat_amount }.round(2)
      end
      @graph_title = graph_data.title
    end

    private

    def parse_time(date)
      Time.zone.parse("#{params["#{date}(3i)"]}-#{params["#{date}(2i)"]}-#{params["#{date}(1i)"]}")
    end

    def set_times
      @from = parse_time('date_from') || Time.current.at_beginning_of_month
      @to = parse_time('date_to')
      @current_month_end = Time.current.at_end_of_month
      @six_months_ago = 5.months.ago.at_beginning_of_month
    end

    def ordered_fee_schemes
      @ordered_fee_schemes ||= FeeScheme.where(name: %w[AGFS LGFS]).order(:name, :version)
                                        .map { |scheme| "#{scheme.name} #{scheme.version}" }
    end

    def last_six_months
      output = []
      6.times do |offset|
        month = (Time.current.end_of_month - offset.month).strftime('%b')
        output << month
      end
      output.reverse
    end

    def empty_linechart_array
      output = []
      ordered_fee_schemes.each do |scheme|
        output.append({ name: scheme, data: Hash.new(0) })
        last_six_months.each do |month|
          output[-1][:data][month] = 0
        end
      end
      output
    end

    def generate_six_month_breakdown
      @six_month_breakdown = empty_linechart_array

      Claim::BaseClaim.active.non_draft.where(last_submitted_at:
                                                @six_months_ago..@current_month_end).find_each do |claim|
        @six_month_breakdown.each do |hash|
          if hash[:name] == "#{claim.fee_scheme.name} #{claim.fee_scheme.version}"
            hash[:data][claim.last_submitted_at.strftime('%b')] += 1
          end
        end
      end
    end
  end
end
