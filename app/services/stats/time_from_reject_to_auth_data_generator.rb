module Stats
  class TimeFromRejectToAuthDataGenerator < BaseDataGenerator

    private

    def report_types
      {
        'time_reject_to_auth' => 'in days'
      }
    end

    def transform_data_value(value)
      # transform value on statistics table which is in seconds to days
      (value / 60.0 / 60 / 24).round(2)
    end
  end
end