module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show
    def show
      @date_err = false
      set_times
      @dummy_data_1 = { 'AGFS 9': 2,
                        'AGFS 10': 10,
                        'AGFS 11': 12,
                        'AGFS 13': 8,
                        'AGFS 14': 15,
                        'AGFS 15': 22,
                        'LGFS 9': 8,
                        'LGFS 10': 33 }
      @dummy_data_2 = { 'AGFS 9': 34.56,
                        'AGFS 10': 1000.34,
                        'AGFS 11': 120.43,
                        'AGFS 13': 86.78,
                        'AGFS 14': 153.29,
                        'AGFS 15': 2030.45,
                        'LGFS 9': 135.65,
                        'LGFS 10': 2582.56 }
      @dummy_data_3 = Claim::BaseClaim.group_by_day(:last_submitted_at).count
    end

    def set_times
      if params['date_from(3i)'].nil?
        set_default_dates
      else
        process_dates
        if invalid_dates?
          @date_err = true
          set_default_dates
        else
          set_provided_dates
        end
      end
    end

    def set_default_dates
      @from = Time.zone.today.at_beginning_of_month.to_formatted_s(:short)
      @to = Time.zone.today.to_formatted_s(:short)
    end

    def process_dates
      @from_input = "#{params['date_from(3i)']}-#{params['date_from(2i)']}-#{params['date_from(1i)']}"
      @to_input = "#{params['date_to(3i)']}-#{params['date_to(2i)']}-#{params['date_to(1i)']}"
    end

    def set_provided_dates
      @from = Date.parse(@from_input).to_formatted_s(:short)
      @to = Date.parse(@to_input).to_formatted_s(:short)
    end

    def invalid_dates?
      return true if @from_input > @to_input

      begin
        from_test = Date.parse(@from_input)
        to_test = Date.parse(@to_input)
        false
      rescue Date::Error
        true
      end
    end
  end
end
