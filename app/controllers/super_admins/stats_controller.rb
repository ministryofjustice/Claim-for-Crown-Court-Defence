module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show

    def show
      @date_err = false
      @total_claims = empty_results_hash
      @total_values = empty_results_hash
      @six_month_breakdown = empty_linechart_array
      set_colours
      process_dates
      set_times
      retrieve_data
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
      begin
        return true if ActiveSupport::TimeZone['UTC'].parse(@from_input).nil?
        return true if ActiveSupport::TimeZone['UTC'].parse(@to_input).nil?
      rescue NoMethodError
        return false
      end
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
        output[scheme] = 0
      end
      output
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

    def retrieve_data
      Claim::BaseClaim.active.non_draft.where(last_submitted_at: @from..@to).find_each do |claim|
        fee_scheme = "#{claim.fee_scheme.name} #{claim.fee_scheme.version}"
        @total_claims[fee_scheme] += 1
        @total_values[fee_scheme] += (claim.total.to_f + claim.vat_amount.to_f)
      end

      generate_six_month_breakdown
    end

    def generate_six_month_breakdown
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
