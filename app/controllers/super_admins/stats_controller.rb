module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show

    def show
      @date_err = false
      set_colours
      process_dates
      set_times
      retrieve_data
      @dummy_data_1 = { 'AGFS 9': 34.56,
                        'AGFS 10': 1000.34,
                        'AGFS 11': 120.43,
                        'AGFS 12': 342,
                        'AGFS 13': 86.78,
                        'AGFS 14': 153.29,
                        'AGFS 15': 2030.45,
                        'LGFS 9': 135.65,
                        'LGFS 10': 2582.56 }
      @dummy_data_2 = { 'AGFS 9': 34.56,
                        'AGFS 10': 1000.34,
                        'AGFS 11': 120.43,
                        'AGFS 12': 342,
                        'AGFS 13': 86.78,
                        'AGFS 14': 153.29,
                        'AGFS 15': 2030.45,
                        'LGFS 9': 135.65,
                        'LGFS 10': 2582.56 }

    end

    def set_colours
      @chart_colours = %w[#ffdd00	#00703c #5694ca #912b88 #f47738 #85994b #003078 #f499be #b52c17 #ea7361 #66ff66].freeze
    end

    def set_times
      @current_month_end = Time.current.at_end_of_month
      @six_months_ago = 5.months.ago.at_beginning_of_month
      if params['date_from(3i)'].nil?
        set_default_dates
      elsif invalid_dates?
        @date_err = true
        set_default_dates
      else
        set_provided_dates
      end
    end

    def set_default_dates
      @from = Time.zone.now.at_beginning_of_month
      @from_str = @from.strftime('%d %b')
      @to = Time.zone.now
      @to_str = @to.strftime('%d %b')

    end

    def process_dates
      @from_input = "#{params['date_from(3i)']}-#{params['date_from(2i)']}-#{params['date_from(1i)']}"
      @to_input = "#{params['date_to(3i)']}-#{params['date_to(2i)']}-#{params['date_to(1i)']}"
    end

    def set_provided_dates
      @from = ActiveSupport::TimeZone['UTC'].parse(@from_input)
      @from_str = @from.strftime('%d %b')

      @to = ActiveSupport::TimeZone['UTC'].parse(@to_input)
      @to_str = @to.strftime('%d %b')

    end

    def invalid_dates?
      return true if @from_input > @to_input
      return true if ActiveSupport::TimeZone['UTC'].parse(@from_input).nil?
      return true if ActiveSupport::TimeZone['UTC'].parse(@to_input).nil?
      false
    end

    def claims
      @claims ||= Claim::BaseClaim.active.non_draft
    end

    def ordered_fee_schemes
      @ordered_fee_schemes ||= FeeScheme.where(name: %w[AGFS LGFS]).order(:name, :version)
                                        .map { |scheme| "#{scheme.name} #{scheme.version}" }
    end

    def empty_results_hash
      output = {}
      ordered_fee_schemes.each do |scheme|
        # Hash default set to 0 to simplify building the results csv
        output[scheme] = Hash.new(0)
      end
      output
    end

    def empty_linechart_array
      output = []
      ordered_fee_schemes.each do |scheme|
        output.append({name: scheme, data: Hash.new(0)})
      end
      output
    end

    def retrieve_data
      @total_claims = empty_results_hash
      @total_values = empty_results_hash
      @six_month_breakdown = empty_linechart_array

      Claim::BaseClaim.active.non_draft.where(last_submitted_at:
                                                @six_months_ago..@current_month_end).find_each do |claim|
        six_month_breakdown(claim)
      end
    end

    def six_month_breakdown(claim)
      @six_month_breakdown.each do |hash|
        if hash[:name] == "#{claim.fee_scheme.name} #{claim.fee_scheme.version}"
          hash[:data][claim.last_submitted_at.strftime('%b')] += 1
        end
      end
    end
  end
end
