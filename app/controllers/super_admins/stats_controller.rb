module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show

    def show
      @chart_colours = %w[#ffdd00	#00703c #5694ca #912b88 #f47738 #85994b #003078 #f499be #b52c17 #ea7361 #66ff66]
      generate_pie_column_charts
      generate_six_month_breakdown
      @total_claims = Stats::Graphs::Data.new(from: @from, to: @to).call
    end

    private

    def parse_time(date)
      Time.zone.parse("#{params["#{date}(3i)"]}-#{params["#{date}(2i)"]}-#{params["#{date}(1i)"]}")
    end

    def set_times
      @from = parse_time('date_from')
      @to = parse_time('date_to')
      @current_month_end = Time.current.at_end_of_month
      @six_months_ago = 5.months.ago.at_beginning_of_month
    end

    def validate_times
      return unless @to.nil? || @from.nil? || @to.before?(@from)
      @date_err = true unless params['date_to(3i)'].nil?
      @from = Time.zone.now.at_beginning_of_month
      @to = Time.zone.now
    end

    def claims_by_fee_scheme
      @claims_by_fee_scheme ||= Claim::BaseClaim.active.non_draft
                                                .where(last_submitted_at: @from..@to).find_each
                                                .group_by(&:fee_scheme)
                                                .sort_by { |fee_scheme, _claims| [fee_scheme.name, fee_scheme.version] }
                                                .to_h
                                                .transform_keys { |fee_scheme| "#{fee_scheme.name} #{fee_scheme.version}" }
    end

    def retrieve_data
      @total_values = claims_by_fee_scheme.transform_values do |claims|
        claims.sum { |claim| claim.total + claim.vat_amount }.round(2)
      end
    end

    def generate_pie_column_charts
      set_times
      validate_times
      retrieve_data
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
